require 'minitest/autorun'
require 'ballistics/projectile'

include Ballistics

describe Projectile do
  before do
    @test_data = {
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

  describe "base" do
    it "must normalize common base specifiers" do
      ["flat", "fb", "f-b", "f_b", "f b",
       "flat-base", "flat_base", "flatbase", "flat base"].each { |valid|
        Projectile.base(valid).must_equal "flat"
        Projectile.base(valid.upcase).must_equal "flat"
      }

      ["boat", "bt", "b-t", "b_t", "b t",
       "boat-tail", "boat_tail", "boattail", "boat tail"].each { |valid|
        Projectile.base(valid).must_equal "boat"
        Projectile.base(valid.upcase).must_equal "boat"
      }
    end

    it "must reject invalid base specifiers" do
      ["flute", "fbase", "foo",
       "brat", "btail", "bar"].each { |invalid|
        proc { Projectile.base(invalid) }.must_raise RuntimeError
        proc { Projectile.base(invalid.upcase) }.must_raise RuntimeError
      }
    end
  end

  describe "new instance" do
    before do
      @prj = Projectile.new(@test_data)
      @prj_ex = Projectile.new(@test_data.merge(@extra_data))
    end

    it "must raise with insufficient parameters" do
      params = {}
      proc { Projectile.new params }.must_raise Exception
      # accumulate the mandatory fields in params
      # note, one of Projectile::BALLISTIC_COEFFICIENT is also mandatory
      Projectile::MANDATORY.keys.each { |mfield|
        params[mfield] = @test_data.fetch(mfield)
        proc { Projectile.new params }.must_raise Exception
      }
      bc = { 'g1' => 0.123 }
      proc { Projectile.new bc }.must_raise Exception
      Projectile.new(params.merge(bc)).must_be_kind_of Projectile
    end

    it "must have a name" do
      @prj.name.wont_be_nil
      @prj.name.must_equal @test_data["name"]
    end

    it "must have a caliber" do
      @prj.cal.wont_be_nil
      @prj.cal.must_equal @test_data["cal"]
    end

    it "must have grains" do
      @prj.grains.wont_be_nil
      @prj.grains.must_equal @test_data["grains"]
    end

    it "must have a ballistic coefficient" do
      bc = @prj.ballistic_coefficient
      bc.wont_be_nil
      bc.must_be_kind_of Hash
      bc.wont_be_empty
      ["g1", "g7"].each { |drag_model|
        test_bc = @test_data[drag_model]
        if test_bc
          bc[drag_model].must_equal test_bc
          @prj.send(drag_model).must_equal test_bc
        else
          bc[drag_model].must_be_nil
          @prj.send(drag_model).must_be_nil
        end
      }
    end

    it "must accept optional fields" do
      Projectile::OPTIONAL.keys.each { |k|
        if @test_data.key?(k)
          @prj.send(k).must_equal @test_data[k]
        else
          @prj.send(k).must_be_nil
        end
      }
    end

    it "must retain initializing data" do
      @prj.yaml_data.must_equal @test_data
      @prj_ex.yaml_data.must_equal @test_data.merge(@extra_data)
    end

    it "must retain extra data" do
      @prj.extra.must_be_empty
      @prj_ex.extra.wont_be_empty
      @prj_ex.extra.must_equal @extra_data
    end
  end

  describe Projectile::DRAG_FUNCTION do
    it "must match keys to Projectile.base" do
      Projectile::DRAG_FUNCTION.keys.each { |k|
        Projectile.base(k).must_equal k
      }
    end

    it "must match values to C::BALLISTIC_COEFFICIENT" do
      Projectile::DRAG_FUNCTION.values.each { |v|
        Projectile::BALLISTIC_COEFFICIENT.key?(v).must_equal true
      }
    end
  end

  describe "drag_function" do
    before do
      # Set up various combinations of flat/boat and g1/g7
      flat = @test_data.merge("base" => "flat")
      flat.delete("g1")
      flat.delete("g7")
      boat = flat.merge("base" => "boat")
      g1 = { "g1" => 0.123 }
      g7 = { "g7" => 0.789 }
      @f1 = flat.merge(g1)
      @f7 = flat.merge(g7)
      @f17 = flat.merge(g1).merge(g7)
      @b1 = boat.merge(g1)
      @b7 = boat.merge(g7)
      @b17 = boat.merge(g1).merge(g7)
    end

    it "must use the preferred nomenclature" do
      Projectile.new(@f1).drag_function.must_equal "g1"
      Projectile.new(@f7).drag_function.must_equal "g7"
      Projectile.new(@f17).drag_function.must_equal "g1"

      Projectile.new(@b1).drag_function.must_equal "g1"
      Projectile.new(@b7).drag_function.must_equal "g7"
      Projectile.new(@b17).drag_function.must_equal "g7"
    end
  end
end
