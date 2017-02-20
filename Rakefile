begin
  gem "rake-compiler"
  require "rake/extensiontask"

  Rake::ExtensionTask.new "ballistics" do |ext|
    ext.lib_dir = "lib/ballistics"
  end
rescue
  nil
end

desc "Run rspec tests"
task :test do
  sh "rspec -I lib spec"
end
