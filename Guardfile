guard :rspec, cmd: 'bundle exec rspec', all_on_start: false do
  watch(%r{^spec/(.+)_spec\.rb$})
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^slack-applybot/commands/(.+)\.rb$}) { |m| "spec/commands/#{m[1]}_spec.rb" }
end

guard :rubocop, all_on_start: false do
  watch(%r{/.+\.rb$})
  watch(%r{(?:.+/)?\.(rubocop|rubocop_todo)\.yml$}) { |m| File.dirname(m[0]) }
end
