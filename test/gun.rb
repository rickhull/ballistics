require 'minitest/autorun'
require 'ballistics/gun'

describe Ballistics::Gun do
  G = Ballistics::Gun

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
      @gun = G.new(@test_data)
      @gun_ex = G.new(@test_data.merge(@extra_data))
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
      G::OPTIONAL.keys.each { |k|
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
end
