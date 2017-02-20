# Created on 2013-05-14
require_relative "../../lib/ballistics/atmosphere"

describe Ballistics::Atmosphere do
  let(:atmosphere) { Ballistics::Atmosphere.new(altitude: 5430, barometric_pressure: 29.93, temperature: 40, relative_humidity: 0.48) }

  it 'returns a corrected BC' do
    expect(atmosphere.correct_ballistic_coefficient(0.338).round(3).to_f).to eq 0.392
  end
end
