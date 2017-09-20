require 'ballistics'
require 'ballistics/atmosphere'

describe Ballistics do
  let(:atmosphere) do
    Ballistics::Atmosphere.new(altitude: 5430,
                               humidity: 0.48,
                               pressure: 29.93,
                               temp: 40)
  end

  let(:zero_options) do
    { drag_function: 'G1',
      ballistic_coefficient: 0.5,
      velocity: 1200,
      sight_height: 1.6,
      zero_range: 100, }
  end

  let(:trajectory_result) do
    Ballistics.trajectory(drag_function: 'G1',
                          ballistic_coefficient: 0.5,
                          velocity: 2850,
                          sight_height: 1.6,
                          wind_speed: 10,
                          wind_angle: 90,
                          zero_range: 200,
                          max_range: 1000,
                          atmosphere: atmosphere,
                          interval: 25)
  end

  let(:bad_params) do
    Ballistics.trajectory(drag_function: 'G1',
                          ballistic_coefficient: 0.5,
                          velocity: 2850)
  end

  describe Ballistics::Atmosphere do
    it 'translates a ballistic coefficient' do
      expect(atmosphere.translate(0.338).round(3).to_f).to eq 0.392
    end
  end

  it 'calculates a zero angle' do
    expect(Ballistics.zero_angle(zero_options).round(6)).to eq 0.227188
  end

  it 'raises an error with incomplete params' do
    expect{ bad_params }.to raise_error(StandardError)
  end

  it 'returns the range' do
    expect(trajectory_result[2]['range']).to eq 50
    expect(trajectory_result[4]['range']).to eq 100
    expect(trajectory_result[8]['range']).to eq 200
    expect(trajectory_result[12]['range']).to eq 300
    expect(trajectory_result[16]['range']).to eq 400
    expect(trajectory_result[20]['range']).to eq 500
    expect(trajectory_result[40]['range']).to eq 1000
  end

  it 'returns the path' do
    expect(trajectory_result[2]['path'].round(1)).to eq 0.6
    expect(trajectory_result[4]['path'].round(1)).to eq 1.6
    expect(trajectory_result[8]['path'].round(1)).to eq 0
    expect(trajectory_result[12]['path'].round(1)).to eq -7
    expect(trajectory_result[16]['path'].round(1)).to eq -20.1
    expect(trajectory_result[20]['path'].round(1)).to eq -40.1
    expect(trajectory_result[40]['path'].round(1)).to eq -282.5
  end

  it 'returns the velocity' do
    expect(trajectory_result[2]['velocity'].to_i).to eq 2769
    expect(trajectory_result[4]['velocity'].to_i).to eq 2691
    expect(trajectory_result[8]['velocity'].to_i).to eq 2538
    expect(trajectory_result[12]['velocity'].to_i).to eq 2390
    expect(trajectory_result[16]['velocity'].to_i).to eq 2246
    expect(trajectory_result[20]['velocity'].to_i).to eq 2108
    expect(trajectory_result[40]['velocity'].to_i).to eq 1500
  end

  it 'returns the moa correction' do
    expect(trajectory_result[2]['moa_correction'].round(1)).to eq -1.1
    expect(trajectory_result[4]['moa_correction'].round(1)).to eq -1.5
    expect(trajectory_result[8]['moa_correction'].round(1)).to eq 0
    expect(trajectory_result[12]['moa_correction'].round(1)).to eq 2.2
    expect(trajectory_result[16]['moa_correction'].round(1)).to eq 4.8
    expect(trajectory_result[20]['moa_correction'].round(1)).to eq 7.7
    expect(trajectory_result[40]['moa_correction'].round(1)).to eq 27
  end

  it 'returns the windage' do
    expect(trajectory_result[2]['windage'].round(1)).to eq 0.2
    expect(trajectory_result[4]['windage'].round(1)).to eq 0.6
    expect(trajectory_result[8]['windage'].round(1)).to eq 2.3
    expect(trajectory_result[12]['windage'].round(1)).to eq 5.2
    expect(trajectory_result[16]['windage'].round(1)).to eq 9.4
    expect(trajectory_result[20]['windage'].round(1)).to eq 15.2
    expect(trajectory_result[40]['windage'].round(1)).to eq 71.3
  end

  it 'returns the moa correction for wind drift windage' do
    expect(trajectory_result[2]['moa_windage'].round(1)).to eq 0.3
    expect(trajectory_result[4]['moa_windage'].round(1)).to eq 0.5
    expect(trajectory_result[8]['moa_windage'].round(1)).to eq 1.1
    expect(trajectory_result[12]['moa_windage'].round(1)).to eq 1.6
    expect(trajectory_result[16]['moa_windage'].round(1)).to eq 2.3
    expect(trajectory_result[20]['moa_windage'].round(1)).to eq 2.9
    expect(trajectory_result[40]['moa_windage'].round(1)).to eq 6.8
  end
end
