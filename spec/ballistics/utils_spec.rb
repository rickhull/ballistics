require "ballistics/utils"

describe Ballistics do
  context 'Bullet Calculations' do
    it 'calculates sectional density' do
      expect(Ballistics.sectional_density(230, 0.451).round(3)).to eq 0.162
    end
  end

  context 'Energy Calculations' do
    it 'calculates kinetic energy' do
      expect(Ballistics.kinetic_energy(800.0, 230).round(2)).to eq 326.78
    end

    it 'calculates Taylor Knockout values' do
      expect(Ballistics.taylor_ko(800.0, 230, 0.452).round(0)).to eq 12
    end
  end

  context 'Recoil Calculations' do
    it 'calculates recoil impulse' do
      expect(Ballistics.recoil_impulse(150, 46, 2800).round(2)).to eq 2.68
    end

    it 'calculates free recoil' do
      expect(Ballistics.free_recoil(150, 46, 2800, 8).round(1)).to eq 10.8
    end

    it 'calculates recoil energy' do
      expect(Ballistics.recoil_energy(150, 46, 2800, 8).round(1)).to eq 14.5
    end
  end
end
