require 'minitest/autorun'
require 'ballistics/cartridge'

include Ballistics

describe Cartridge do
  before do
    @test_data = {
      "name" => "Test Cartridge",
      "case" => "test case",
      "projectile" => "test_projectile",
      "20_inch_fps" => 2000,
      "desc" => "Test Cartridge for test purposes",
    }
    @extra_data = {
      "foo" => "bar",
    }
  end

  describe "BARREL_LENGTH_REGEX" do
    it "must match and extract barrel lengths" do
      ["16_inch_fps", "1_inch_fps", "21_inch_fps"].each { |valid|
        rgx = Cartridge::BARREL_LENGTH_REGEX
        matches = rgx.match valid
        expect(matches).wont_be_nil
        expect(matches.captures).wont_be_empty
      }
    end
  end

  describe "new instance" do
    before do
      @cart = Cartridge.new(@test_data)
      @cart_ex = Cartridge.new(@test_data.merge(@extra_data))
    end

    it "must raise with insufficient parameters" do
      params = {}
      expect(proc { Cartridge.new params }).must_raise Exception
      # Accumulate the mandatory fields in params
      # Note, a field matching Cartridge::BARREL_LENGTH_REGEX is also mandatory
      Cartridge::MANDATORY.keys.each { |mfield|
        params[mfield] = @test_data[mfield]
        expect(proc { Cartridge.new params }).must_raise Exception
      }
      mv = { "15_inch_fps" => 15 }
      expect(proc { Cartridge.new mv }).must_raise Exception
      expect(Cartridge.new(params.merge(mv))).must_be_kind_of Cartridge
    end

    it "must have a name" do
      expect(@cart.name).wont_be_nil
      expect(@cart.name).must_equal @test_data["name"]
    end

    it "must have a case" do
      expect(@cart.case).wont_be_nil
      expect(@cart.case).must_equal @test_data["case"]
    end

    it "must have a projectile" do
      expect(@cart.projectile).wont_be_nil
      expect(@cart.projectile).must_equal @test_data["projectile"]
    end

    it "must have a muzzle velocity" do
      mv = @cart.muzzle_velocity
      expect(mv).wont_be_nil
      expect(mv).must_be_kind_of Hash
      expect(mv).wont_be_empty
      ["16", "20"].each { |barrel_length|
        test_mv = @test_data[barrel_length]
        if test_mv
          expect(mv[barrel_length]).must_equal test_mv
        else
          expect(mv[barrel_length]).must_be_nil
        end
      }
    end

    it "must accept optional fields" do
      Cartridge::OPTIONAL.keys.each { |k|
        if @test_data[k].nil?
          expect(@cart.send(k)).must_be_nil
        else
          expect(@cart.send(k)).must_equal @test_data[k]
        end
      }
    end

    it "must retain initializing data" do
      expect(@cart.yaml_data).must_equal @test_data
      expect(@cart_ex.yaml_data).must_equal @test_data.merge(@extra_data)
    end

    it "must retain extra data" do
      expect(@cart.extra).must_be_empty
      expect(@cart_ex.extra).wont_be_empty
      expect(@cart_ex.extra).must_equal @extra_data
    end
  end

  describe "muzzle velocity" do
    before do
      # we need a valid case -- e.g. 300 BLK
      @cart = Cartridge.new(@test_data.merge("case" => "300 BLK"))
    end

    it "must estimate an unknown muzzle velocity" do
      # sanity checks
      expect(Cartridge::BURN_LENGTH[@cart.case]).wont_be_nil
      expect(@test_data["20_inch_fps"]).wont_be_nil
      expect(@test_data["19_inch_fps"]).must_be_nil
      expect(@test_data["21_inch_fps"]).must_be_nil

      expect(@cart.mv(20)).must_equal @test_data["20_inch_fps"]
      expect(@cart.mv(20.9)).must_equal @test_data["20_inch_fps"]
      expect(@cart.mv(19.1)).must_equal @test_data["20_inch_fps"]
    end
  end
end
