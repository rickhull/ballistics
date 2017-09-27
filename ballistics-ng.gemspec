Gem::Specification.new do |s|
  s.name = 'ballistics-ng'
  s.summary = 'Ballistics library for calculating small arms trajectories'
  s.author = 'Rick Hull'
  s.homepage = 'https://github.com/rickhull/ballistics'
  s.license = 'GPL-3.0'
  s.has_rdoc = true
  s.description = <<EOF
Ballistics-ng is based (currently) on C code derived from the GNU Ballistics project; this gem is originally based on the ballistics gem, which was abandoned in 2013.  Very little code remains from that project.
EOF

  s.files = %w(
lib/ballistics.rb
lib/ballistics/atmosphere.rb
lib/ballistics/cartridge.rb
lib/ballistics/cartridges/300_blk.yaml
lib/ballistics/gun.rb
lib/ballistics/guns/pistols.yaml
lib/ballistics/guns/rifles.yaml
lib/ballistics/guns/shotguns.yaml
lib/ballistics/problem.rb
lib/ballistics/projectile.rb
lib/ballistics/projectiles/300_blk.yaml
lib/ballistics/util.rb
lib/ballistics/yaml.rb
README.md
Rakefile
examples/table.rb
ext/ballistics/ext.c
ext/ballistics/extconf.rb
ext/ballistics/gnu_ballistics.h
test/atmosphere.rb
test/ballistics.rb
test/cartridge.rb
test/gun.rb
test/problem.rb
test/projectile.rb
test/util.rb
)
  s.extensions << "ext/ballistics/extconf.rb"
  s.required_ruby_version = "~> 2"

  s.add_development_dependency "buildar", '~> 3'
  s.add_development_dependency "rake-compiler", '~> 1'

  s.version = File.read(File.join(__dir__, 'VERSION')).chomp
end
