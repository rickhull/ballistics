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
      expect(@gun.name).wont_be_nil
      expect(@gun.name).must_equal @test_data["name"]
    end

    it "must have a chamber" do
      expect(@gun.chamber).wont_be_nil
      expect(@gun.chamber).must_equal @test_data["chamber"]
    end

    it "must have a barrel_length" do
      expect(@gun.barrel_length).wont_be_nil
      expect(@gun.barrel_length).must_equal @test_data["barrel_length"]
    end

    it "must have a sight_height" do
      expect(@gun.sight_height).wont_be_nil
      expect(@gun.sight_height).must_equal @test_data["sight_height"]
    end

    it "must accept optional fields" do
      Gun::OPTIONAL.keys.each { |k|
        if @test_data.key?(k)
          expect(@gun.send(k)).must_equal @test_data[k]
        else
          expect(@gun.send(k)).must_be_nil
        end
      }
    end

    it "must retain initializing data" do
      expect(@gun.yaml_data).must_equal @test_data
      expect(@gun_ex.yaml_data).must_equal @test_data.merge(@extra_data)
    end

    it "must retain extra data" do
      expect(@gun.extra).must_be_empty
      expect(@gun_ex.extra).wont_be_empty
      expect(@gun_ex.extra).must_equal @extra_data
    end
  end

  describe "cartridges" do
    it "must recognize known cartridges" do
      ["300 BLK"].each { |valid|
        # sanity check
        expect(Gun::CHAMBER_CARTRIDGE.key?(valid)).must_equal true
        gun = Gun.new @test_data.merge("chamber" => valid)
        expect(gun.cartridges).must_be_kind_of Hash
      }
    end
  end

  it "must reject an unknown cartridge" do
    invalid = { "chamber" => "501 Levis" }
    gun = Gun.new @test_data.merge(invalid)
    expect(proc { gun.cartridges }).must_raise Gun::ChamberNotFound
  end
end
