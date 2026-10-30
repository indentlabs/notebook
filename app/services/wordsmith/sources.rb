require 'digest'
require 'net/http'
require 'rubygems/package'
require 'zlib'

# Fetches the pinned, open-licensed data packages Wordsmith is built from.
#
# The packages are downloaded from the npm registry (immutable, versioned
# tarballs) and checked against the integrity hashes below, so an import is
# reproducible and can't silently pick up changed data. This only runs during
# `rake wordsmith:import`; the app never makes these requests while serving.
#
# To import without network access, extract the packages yourself and point
# WORDSMITH_SOURCE_DIR at a directory containing wordnet-db/, cmu-pronouncing-dictionary/
# and moby/ folders laid out like the npm packages.
module Wordsmith
  class Sources
    PACKAGES = {
      'wordnet-db' => {
        url:       'https://registry.npmjs.org/wordnet-db/-/wordnet-db-3.1.14.tgz',
        integrity: 'sha512-zVyFsvE+mq9MCmwXUWHIcpfbrHHClZWZiVOzKSxNJruIcFn2RbY55zkhiAMMxM8zCVSmtNiViq8FsAZSFpMYag=='
      },
      'cmu-pronouncing-dictionary' => {
        url:       'https://registry.npmjs.org/cmu-pronouncing-dictionary/-/cmu-pronouncing-dictionary-3.0.0.tgz',
        integrity: 'sha512-6y5X4OxsYFnHERo6WSVPnLrk53G07MOQ8aUb2z555JgwynpbZsHR0a//WdN6DUcmE1j2auTF2TtL4PpoKze8QQ=='
      },
      'moby' => {
        url:       'https://registry.npmjs.org/moby/-/moby-1.1.2.tgz',
        integrity: 'sha512-1tFwOBa+vg02pjXAlyrOFRVTmXrhwNh5Eo+MldHRLT/pnpibe6B03jQYv9KKmv1WrGbBh0VPt7MqT+Y8geqoCg=='
      }
    }.freeze

    attr_reader :directory

    def initialize(directory: ENV['WORDSMITH_SOURCE_DIR'].presence || Rails.root.join('tmp', 'wordsmith').to_s)
      @directory = directory
    end

    def fetch!
      PACKAGES.each do |name, package|
        next if File.directory?(File.join(directory, name))

        tarball = download(package[:url])
        verify!(name, tarball, package[:integrity])
        extract(tarball, File.join(directory, name))
      end

      self
    end

    def importer_options
      {
        wordnet_dir: File.join(directory, 'wordnet-db', 'dict'),
        cmu_file:    File.join(directory, 'cmu-pronouncing-dictionary', 'index.js'),
        moby_file:   File.join(directory, 'moby', 'words.txt')
      }
    end

    private

    def download(url, redirects = 3)
      response = Net::HTTP.get_response(URI(url))
      return download(response['location'], redirects - 1) if response.is_a?(Net::HTTPRedirection) && redirects.positive?
      raise "Wordsmith: failed to download #{url} (HTTP #{response.code})" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    def verify!(name, tarball, integrity)
      actual = "sha512-#{Digest::SHA512.base64digest(tarball)}"
      raise "Wordsmith: integrity check failed for #{name}" unless actual == integrity
    end

    # npm tarballs wrap everything in a top-level package/ folder; strip it.
    def extract(tarball, destination)
      FileUtils.mkdir_p(destination)

      Gem::Package::TarReader.new(Zlib::GzipReader.new(StringIO.new(tarball))) do |tar|
        tar.each do |entry|
          next unless entry.file?

          relative = entry.full_name.sub(%r{\A[^/]+/}, '')
          path = File.expand_path(relative, destination)
          raise "Wordsmith: unsafe path in archive: #{entry.full_name}" unless path.start_with?(File.expand_path(destination) + '/')

          FileUtils.mkdir_p(File.dirname(path))
          File.binwrite(path, entry.read)
        end
      end
    end
  end
end
