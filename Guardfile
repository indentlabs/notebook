# A sample Guardfile
# More info at https://github.com/guard/guard#readme

ENV['coverage'] = 'no'

group :default do
  guard :rubocop, all_on_start: false, keep_failed: false, cli: '--rails --format simple' do
    watch(/.+\.rb$/)
    watch(%r{(?:.+/)?.rubocop.yml$}) { |m| File.dirname(m[0]) }
  end

  guard :minitest, spring: false, all_on_start: false, all_after_pass: false, keep_failed: true do
    # with Minitest::Test
    watch(%r{^test/(.*)_test\.rb})

    # Rails 4
    watch(%r{^test/test_helper\.rb}) { 'test' }
    watch(%r{^test/.+_test\.rb})
    watch(%r{^app/(.+)\.rb})                               { |m| "test/#{m[1]}_test.rb" }
    watch(%r{^app/controllers/application_controller\.rb}) { 'test/controllers' }
    watch(%r{^app/controllers/(.+)_controller\.rb})        { |m| "test/controllers/#{m[1]}_controller_test.rb" }
    watch(%r{^lib/(.+)\.rb})                               { |m| "test/lib/#{m[1]}_test.rb" }
  end
end
