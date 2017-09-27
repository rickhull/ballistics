begin
  require "rake/testtask"

  # add test task
  Rake::TestTask.new do |t|
    t.test_files = FileList['test/**/*.rb']
  end
  desc "Run minitest tests"

  task default: :test

  @test_task = true
rescue Exception => e
  warn "testtask error: #{e}"
  @test_task = false
end

begin
  gem "rake-compiler"
  require "rake/extensiontask"

  # add tasks for compilation
  Rake::ExtensionTask.new "ballistics/ext" do |t|
    t.lib_dir = "lib"
    t.ext_dir = "ext/ballistics"
  end

  # add rebuild task
  if @test_task
    desc "clobber, compile, test"
    task rebuild: [:clobber, :compile, :test]
  else
    desc "clobber, compile"
    task rebuild: [:clobber, :compile]
  end
rescue Exception => e
  warn "rake-compiler error: #{e}"
end

begin
  require 'buildar'

  # add gem building tasks
  Buildar.new do |b|
    b.gemspec_file = 'ballistics_ng.gemspec'
    b.version_file = 'VERSION'
    b.use_git = true
  end
rescue LoadError
  # ok
end
