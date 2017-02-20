# Created on 2013-05-14
require_relative "../../lib/ballistics/zero"
require 'ballistics/ballistics'

describe Ballistics::Zero do
  let(:options) do
    { 
      drag_function: 'G1',
      drag_coefficient: 0.5, 
      velocity: 1200, 
      sight_height: 1.6, 
      zero_range: 100
    }
  end

  it 'returns the expected value' do
    expect(Ballistics::Zero.calculate_zero_angle(options).round(6)).to eq 0.227188
  end
end
