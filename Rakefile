require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'bundler/audit/task'

Bundler::Audit::Task.new
RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)

RSpec::Core::RakeTask.new(:integration) do |t|
  t.rspec_opts = '--tag integration'
end

task default: %i[spec rubocop bundle:audit]
