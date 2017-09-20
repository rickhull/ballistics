require 'minitest/autorun'
require 'ballistics/cartridge'

describe Ballistics::Cartridge do
  C = Ballistics::Cartridge

  before do
    @test_data = {
      "name" => "Test Cartridge",
      "case" => "test case",
      "projectile" => "test_projectile",
      "20_inch_fps" => 2000,
      "desc" => "Test Cartridge for test purposes",
    }
    @test_projectile = {
      "name" => "Test Projectile",
      "cal" => 1.0,
      "grains" => 100,
      "g1" => 1.0,
      "sd" => 1.0,
      "intended" => "test purposes",
      "base" => "flat",
      "desc" => "Test Projectile for test purposes",
    }
    @extra_data = {
      "foo" => "bar",
    }
  end


  describe "BARREL_LENGTH_REGEX" do
    it "must match and extract barrel lengths" do
      ["16_inch_fps", "1_inch_fps", "21_inch_fps"].each { |valid|
        rgx = C::BARREL_LENGTH_REGEX
        matches = rgx.match valid
        matches.wont_be_nil
        matches.captures.wont_be_empty
      }
    end
  end

  describe "new instance" do
    before do
      @cart = C.new(@test_data)
      @cart_ex = C.new(@test_data.merge(@extra_data))
    end

    it "must have a name" do
      @cart.name.wont_be_nil
      @cart.name.must_equal @test_data["name"]
    end

    it "must have a case" do
      @cart.case.wont_be_nil
      @cart.case.must_equal @test_data["case"]
    end

    it "must have a projectile" do
      @cart.projectile.wont_be_nil
      @cart.projectile.must_equal @test_data["projectile"]
    end

    it "must have a muzzle velocity" do
      mv = @cart.muzzle_velocity
      mv.wont_be_nil
      mv.must_be_kind_of Hash
      mv.wont_be_empty
      ["16", "20"].each { |barrel_length|
        test_mv = @test_data[barrel_length]
        if test_mv
          mv[barrel_length].must_equal test_mv
        else
          mv[barrel_length].must_be_nil
        end
      }
    end

    it "must accept optional fields" do
      C::OPTIONAL.keys.each { |k|
        if @test_data[k]
          @cart.send(k).must_equal @test_data[k]
        else
          @cart.send(k).must_be_nil
        end
      }
    end

    it "must retain initializing data" do
      @cart.yaml_data.must_equal @test_data
      @cart_ex.yaml_data.must_equal @test_data.merge(@extra_data)
    end

    it "must retain extra data" do
      @cart.extra.must_be_empty
      @cart_ex.extra.wont_be_empty
      @cart_ex.extra.must_equal @extra_data
    end
  end
end
