require_relative '../lib/ballistics'

describe Ballistics do
  let(:environment) { Ballistics.build_environment(altitude: 5430, barometric_pressure: 29.93, temperature: 40, relative_humidity: 0.48) }
  let(:result_array) do 
    Ballistics.map_trajectory(drag_function: 'G1',
                              drag_coefficient: 0.5,
                              velocity: 2850,
                              sight_height: 1.6,
                              wind_speed: 10,
                              wind_angle: 90,
                              zero_range: 200,
                              max_range: 1000,
                              environment: environment,
                              interval: 25)
  end

  let(:bad_params) do
    Ballistics.map_trajectory(drag_function: 'G1', drag_coefficient: 0.5, velocity: 2850)
  end

  it 'returns an environment' do
    expect(environment).to be_an_instance_of Ballistics::Atmosphere
  end

  it 'raises an error with incomplete params' do
    expect{ bad_params }.to raise_error(ArgumentError)
  end

  it 'returns the range' do
    expect(result_array[2]['range']).to eq 50
    expect(result_array[4]['range']).to eq 100
    expect(result_array[8]['range']).to eq 200
    expect(result_array[12]['range']).to eq 300
    expect(result_array[16]['range']).to eq 400
    expect(result_array[20]['range']).to eq 500
    expect(result_array[40]['range']).to eq 1000
  end

  it 'returns the path' do
    expect(result_array[2]['path'].round(1)).to eq 0.6
    expect(result_array[4]['path'].round(1)).to eq 1.6
    expect(result_array[8]['path'].round(1)).to eq 0
    expect(result_array[12]['path'].round(1)).to eq -7
    expect(result_array[16]['path'].round(1)).to eq -20.1
    expect(result_array[20]['path'].round(1)).to eq -40.1
    expect(result_array[40]['path'].round(1)).to eq -282.5
  end

  it 'returns the velocity' do
    expect(result_array[2]['velocity'].to_i).to eq 2769
    expect(result_array[4]['velocity'].to_i).to eq 2691
    expect(result_array[8]['velocity'].to_i).to eq 2538
    expect(result_array[12]['velocity'].to_i).to eq 2390
    expect(result_array[16]['velocity'].to_i).to eq 2246
    expect(result_array[20]['velocity'].to_i).to eq 2108
    expect(result_array[40]['velocity'].to_i).to eq 1500
  end

  it 'returns the moa correction' do
    expect(result_array[2]['moa_correction'].round(1)).to eq -1.1
    expect(result_array[4]['moa_correction'].round(1)).to eq -1.5
    expect(result_array[8]['moa_correction'].round(1)).to eq 0
    expect(result_array[12]['moa_correction'].round(1)).to eq 2.2
    expect(result_array[16]['moa_correction'].round(1)).to eq 4.8
    expect(result_array[20]['moa_correction'].round(1)).to eq 7.7
    expect(result_array[40]['moa_correction'].round(1)).to eq 27
  end

  it 'returns the windage' do
    expect(result_array[2]['windage'].round(1)).to eq 0.2
    expect(result_array[4]['windage'].round(1)).to eq 0.6
    expect(result_array[8]['windage'].round(1)).to eq 2.3
    expect(result_array[12]['windage'].round(1)).to eq 5.2
    expect(result_array[16]['windage'].round(1)).to eq 9.4
    expect(result_array[20]['windage'].round(1)).to eq 15.2
    expect(result_array[40]['windage'].round(1)).to eq 71.3
  end

  it 'returns the moa correction for wind drift windage' do
    expect(result_array[2]['moa_windage'].round(1)).to eq 0.3
    expect(result_array[4]['moa_windage'].round(1)).to eq 0.5
    expect(result_array[8]['moa_windage'].round(1)).to eq 1.1
    expect(result_array[12]['moa_windage'].round(1)).to eq 1.6
    expect(result_array[16]['moa_windage'].round(1)).to eq 2.3
    expect(result_array[20]['moa_windage'].round(1)).to eq 2.9
    expect(result_array[40]['moa_windage'].round(1)).to eq 6.8
  end

end
