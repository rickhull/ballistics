require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/*.rb"
  t.warning = true
end

desc "Run example scripts"
task :examples do
  Dir['examples/**/*.rb'].each { |fn|
    puts
    sh "ruby -Ilib #{fn}"
    puts
  }
end

task default: [:test, :examples]

#
# C EXTENSION
#


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

#
# GEM BUILD / PUBLISH
#


begin
  require 'buildar'

  # add gem building tasks
  Buildar.new do |b|
    b.gemspec_file = 'ballistics-ng.gemspec'
    b.version_file = 'VERSION'
    b.use_git = true
  end
rescue LoadError
  # ok
end
