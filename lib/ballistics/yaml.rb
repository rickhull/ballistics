require 'yaml'

module Ballistics
  def self.load_yaml(filename, built_in = nil)
    candidates = [filename]
    if built_in # check for yaml files built in to this library
      candidates.unshift(File.join(__dir__, built_in, "#{filename}.yaml"))
      candidates.unshift(File.join(__dir__, built_in, filename))
    end
    yaml = nil
    candidates.each { |file|
      if File.readable?(file)
        yaml = YAML.load_file(file)
        break
      end
    }
    yaml or raise("unable to read #{filename}")
  end

  def self.check_type?(val, type)
    case type
    when :string, :reference
      val.is_a?(String)
    when :float
      val.is_a?(Numeric)
    when :count
      val.is_a?(1.class) and val >= 0
    when :int
      val.is_a?(1.class)
    else
      raise "unknown type: #{type}"
    end
  end

  def self.check_type!(val, type)
    self.check_type?(val, type) or raise("val #{val} is not type #{type}")
  end
end
