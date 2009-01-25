require "rubygems"
require "rake/gempackagetask"
require "rubygems/specification"
require "date"
require "spec/rake/spectask"

desc "Run the specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ["--colour --format progress --loadby mtime --reverse"]
  t.spec_files = FileList["spec/**/*_spec.rb"]
end

desc "Run benchmarks"
task :benchmark do
  Dir.glob("benchmark/**/*_bm.rb").each {|f| require f }
end
