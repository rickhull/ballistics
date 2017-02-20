begin
  gem "rspec"

  desc "Run rspec tests"
  task :test do sh "rspec -I lib spec" end
  task spec: :test

  @test_task = true
rescue Exception => e
  warn "rspec error: #{e}"
  @test_task = false
end

begin
  gem "rake-compiler"
  require "rake/extensiontask"

  Rake::ExtensionTask.new "ballistics/ext" do |t|
    t.lib_dir = "lib"
    t.ext_dir = "ext/ballistics"
  end

  @compile_task = true
rescue Exception => e
  warn "rake-compiler error: #{e}"
  @compile_task = false
end

if @test_task and @compile_task
  desc "clobber, compile, test"
  task rebuild: [:clobber, :compile, :test]
  task default: :rebuild
elsif @test_task
  task default: :test
end
