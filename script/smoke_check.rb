#!/usr/bin/env ruby
# Crawls a running copy of the site and fails if any page returns a 5xx.
#
# Run it against staging before promoting a deploy, and against production
# right after one:
#
#   ruby script/smoke_check.rb https://staging.notebook.ai
#
# Signed out, it checks the public pages. To check the signed-in app too, give
# it a dedicated test account (never a real person's) that owns some content:
#
#   SMOKE_EMAIL=smoke@example.com SMOKE_PASSWORD=... ruby script/smoke_check.rb https://staging.notebook.ai
#
# It starts from a handful of key pages and follows links on the same host,
# up to SMOKE_MAX_PAGES (default 300). It never follows links that change
# data with a GET (sign out, unfollow, delete, billing changes, ...): see
# NEVER_FOLLOW. Exits 1 if any page returned a 5xx or couldn't be fetched.
#
# Needs only the Ruby standard library, so it runs anywhere Ruby does.

require 'net/http'
require 'uri'
require 'set'

class SmokeCheck
  START_PATHS = %w[
    /
    /for/writers
    /for/roleplayers
    /help
    /community
    /forum
    /worldbuilding/characters
    /about/privacy
    /about/billing/faq
    /api/docs
  ].freeze

  SIGNED_IN_START_PATHS = %w[
    /my/dashboard
    /my/content/recent
    /my/multiverse
    /plan/universes
    /plan/characters
    /plan/locations
    /plan/items
    /plan/timelines
    /documents
    /books
    /collections
    /stream
    /stream/world
    /my/data
    /my/writing-goals
    /my/billing/subscription
    /users/edit
    /notifications
    /forum
  ].freeze

  # Links that change something when followed with a GET, or that hand off to
  # another service. The crawler must never request these on a real site.
  NEVER_FOLLOW = [
    %r{/logout}, %r{/sign_out},
    %r{/destroy}, %r{/delete}, %r{/remove}, %r{/unlink},
    %r{/follow\b}, %r{/unfollow\b}, %r{/report\b},
    %r{/approve\b}, %r{/pass\b},
    %r{/mark_all_read}, %r{/notice_dismissal},
    %r{/queue_analysis},
    %r{/my/billing/(to|payment_method|prepay_redirect|gift|prepay/paid)},
    %r{/redeem/},
    %r{/admin}, %r{/sidekiq}, %r{/moderation},
    %r{/unsubscribe},
    %r{/save/},                # copies a forum topic into a new document
    %r{/my/data/export},       # heavy downloads, not pages
    %r{/ai/basil/[^/]+/\d+$},  # commission pages can start image generation
    %r{/masquerade},
    %r{/rails/active_storage}, %r{/assets/}, %r{/packs/},
    %r{\.(png|jpe?g|gif|webp|svg|ico|css|js|pdf|zip|csv|json|xml|yml|rss)(\?|$)}i,
  ].freeze

  Result = Struct.new(:path, :status, :error, :from, keyword_init: true)

  def initialize(base_url, email: nil, password: nil, max_pages: 300, delay: 0.2)
    @base      = URI(base_url.chomp('/'))
    @email     = email
    @password  = password
    @max_pages = max_pages
    @delay     = delay
    @cookies   = {}
    @seen      = Set.new
    @queue     = []
    @results   = []
  end

  def run
    sign_in if @email && @password

    start = START_PATHS + (@signed_in ? SIGNED_IN_START_PATHS : [])
    start.each { |path| enqueue(path, from: '(start)') }

    while (item = @queue.shift) && @results.size < @max_pages
      path, from = item
      check(path, from)
      sleep @delay
    end

    report
  end

  private

  def sign_in
    page = request(:get, '/users/sign_in')
    token = page.body.to_s[/name="authenticity_token" value="([^"]+)"/, 1] ||
            page.body.to_s[/<meta name="csrf-token" content="([^"]+)"/, 1]
    response = request(:post, '/users/sign_in', form: {
      'authenticity_token' => token.to_s,
      'user[email]'        => @email,
      'user[password]'     => @password,
    })
    @signed_in = response.is_a?(Net::HTTPRedirection) && !response['location'].to_s.include?('sign_in')
    abort "Couldn't sign in as #{@email} (status #{response.code}). Check SMOKE_EMAIL / SMOKE_PASSWORD." unless @signed_in
    puts "Signed in as #{@email}"
  end

  def check(path, from)
    response = request(:get, path)
    status = response.code.to_i
    @results << Result.new(path: path, status: status, from: from)
    mark = status >= 500 ? 'FAIL' : 'ok  '
    puts "#{mark} #{status} #{path}"

    if response.is_a?(Net::HTTPRedirection)
      enqueue(response['location'], from: path)
    elsif response.content_type.to_s.include?('html')
      links(response.body).each { |link| enqueue(link, from: path) }
    end
  rescue StandardError => e
    @results << Result.new(path: path, error: "#{e.class}: #{e.message}", from: from)
    puts "FAIL --- #{path} (#{e.class}: #{e.message})"
  end

  def links(html)
    # Hrefs inside <script> are JavaScript templates, not links.
    html = html.to_s.gsub(%r{<script\b.*?</script>}mi, '')
    html.scan(/<a\s[^>]*href="([^"#]+)/i).flatten.uniq.reject do |href|
      # Links that send a non-GET request through rails-ujs or Turbo.
      html.include?(%(href="#{href}" data-method=)) || html.include?(%(href="#{href}" data-turbo-method=))
    end
  end

  def enqueue(href, from:)
    uri = URI.join("#{@base}/", href.to_s.gsub('&amp;', '&')) rescue return
    return unless uri.host == @base.host && %w[http https].include?(uri.scheme)

    path = uri.request_uri
    return if NEVER_FOLLOW.any? { |pattern| path.match?(pattern) }
    # Pages that differ only by their query string (pagination, filters) are
    # usually the same template; check a couple, not hundreds.
    template = path.sub(/\?.*/, '').gsub(/\d+/, ':n')
    @template_counts ||= Hash.new(0)
    return if (@template_counts[template] += 1) > 3
    return unless @seen.add?(path)

    @queue << [path, from]
  end

  def request(method, path, form: nil)
    uri = URI.join("#{@base}/", path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.open_timeout = 10
    http.read_timeout = 30

    req = method == :post ? Net::HTTP::Post.new(uri) : Net::HTTP::Get.new(uri)
    req['User-Agent'] = 'NotebookSmokeCheck/1.0'
    req['Accept'] = 'text/html'
    req['Cookie'] = @cookies.map { |k, v| "#{k}=#{v}" }.join('; ') if @cookies.any?
    req.set_form_data(form) if form

    response = http.request(req)
    Array(response.get_fields('set-cookie')).each do |cookie|
      name, value = cookie.split(';').first.split('=', 2)
      @cookies[name] = value
    end
    response
  end

  def report
    failures = @results.select { |r| r.error || r.status.to_i >= 500 }
    puts
    puts "Checked #{@results.size} pages on #{@base}#{' (signed in)' if @signed_in}."

    if failures.empty?
      puts 'No server errors.'
      exit 0
    else
      puts "#{failures.size} page(s) failed:"
      failures.each { |f| puts "  #{f.status || '---'} #{f.path}  (linked from #{f.from})#{"  #{f.error}" if f.error}" }
      exit 1
    end
  end
end

if $PROGRAM_NAME == __FILE__
  base_url = ARGV[0] || ENV['SMOKE_URL']
  abort "Usage: ruby #{__FILE__} https://staging.example.com" if base_url.to_s.empty?

  SmokeCheck.new(
    base_url,
    email:     ENV['SMOKE_EMAIL'],
    password:  ENV['SMOKE_PASSWORD'],
    max_pages: Integer(ENV.fetch('SMOKE_MAX_PAGES', 300)),
    delay:     Float(ENV.fetch('SMOKE_DELAY', 0.2))
  ).run
end
