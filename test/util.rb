require 'minitest/autorun'
require 'ballistics/util'

describe Ballistics do
  it "calculates expected bullet sectional density" do
    Ballistics.sectional_density(230, 0.451).round(3).must_equal 0.162
  end

  it "calculates expected bullet kinetic energy" do
    Ballistics.kinetic_energy(800.0, 230).round(2).must_equal 326.78
  end

  it "calculates expected Taylor Knockout values for a bullet" do
    Ballistics.taylor_ko(800.0, 230, 0.452).round(0).must_equal 12
  end

  it "calculates expected recoil impulse" do
    Ballistics.recoil_impulse(150, 46, 2800).round(2).must_equal 2.68
  end

  it "calculates expected free recoil" do
    Ballistics.free_recoil(150, 46, 2800, 8).round(1).must_equal 10.8
  end

  it "calculates expected recoil energy" do
    Ballistics.recoil_energy(150, 46, 2800, 8).round(1).must_equal 14.5
  end
end
