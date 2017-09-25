require 'minitest/autorun'
require 'ballistics/gun'

include Ballistics

describe Gun do
  before do
    @test_data = {
      "name" => "Test Gun",
      "chamber" => "test chamber",
      "barrel_length" => 16,
      "sight_height" => 1.5,
      "zero_range" => 100,
    }

    @extra_data = {
      "foo" => "bar",
    }
  end

  describe "new instance" do
    before do
      @gun = Gun.new(@test_data)
      @gun_ex = Gun.new(@test_data.merge(@extra_data))
    end

    it "must have a name" do
      @gun.name.wont_be_nil
      @gun.name.must_equal @test_data["name"]
    end

    it "must have a chamber" do
      @gun.chamber.wont_be_nil
      @gun.chamber.must_equal @test_data["chamber"]
    end

    it "must have a barrel_length" do
      @gun.barrel_length.wont_be_nil
      @gun.barrel_length.must_equal @test_data["barrel_length"]
    end

    it "must have a sight_height" do
      @gun.sight_height.wont_be_nil
      @gun.sight_height.must_equal @test_data["sight_height"]
    end

    it "must accept optional fields" do
      Gun::OPTIONAL.keys.each { |k|
        if @test_data.key?(k)
          @gun.send(k).must_equal @test_data[k]
        else
          @gun.send(k).must_be_nil
        end
      }
    end

    it "must retain initializing data" do
      @gun.yaml_data.must_equal @test_data
      @gun_ex.yaml_data.must_equal @test_data.merge(@extra_data)
    end

    it "must retain extra data" do
      @gun.extra.must_be_empty
      @gun_ex.extra.wont_be_empty
      @gun_ex.extra.must_equal @extra_data
    end
  end

  describe "cartridges" do
    it "must recognize known cartridges" do
      ["300 BLK"].each { |valid|
        # sanity check
        Gun::CHAMBER_CARTRIDGE.key?(valid).must_equal true
        gun = Gun.new @test_data.merge("chamber" => valid)
        gun.cartridges.must_be_kind_of Hash
      }
    end
  end

  it "must reject an unknown cartridge" do
    invalid = { "chamber" => "501 Levis" }
    gun = Gun.new @test_data.merge(invalid)
    proc { gun.cartridges }.must_raise Gun::ChamberNotFound
  end
end
