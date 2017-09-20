begin
  gem "rspec"

  desc "Run rspec tests"
  task :spec do
    sh "rspec -Ilib spec"
  end

  @spec_task = true
rescue Exception => e
  warn "rspec error: #{e}"
  @spec_task = false
end

begin
  require "rake/testtask"

  Rake::TestTask.new do |t|
    t.test_files = FileList['test/**/*.rb']
  end
  desc "Run minitest tests"

  @test_task = true
rescue Exception => e
  warn "testtask error: #{e}"
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

@no_tests = false
if @test_task and @spec_task
  task default: [:test, :spec]
elsif @test_task
  task default: :test
elsif @spec_task
  task default: :spec
else
  @no_tests = true
end

if @compile_task and @no_tests
  desc "clobber and compile"
  task rebuild: [:clobber, :compile]
elsif @compile_task
  desc "clobber, compile, test"
  task rebuild: [:clobber, :compile, :default]
end
