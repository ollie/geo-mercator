RSpec.describe Geo::Viewport do
  let(:gps_data) do
    [
      [6.9558,             50.941691666666664],
      [6.956291666666667,  50.94157777777777],
      [6.9201500000000005, 50.948233333333334],
      [9.188316666666667,  45.46555],
      [9.189741666666666,  45.46562222222222],
      [9.185799999999999,  45.46757222222222]
    ]
  end

  let(:viewport) do
    map_bounds = Geo::Utils.bounds(gps_data)
    dimensions = [1280, 960]
    viewport   = Geo::Viewport.new(map_bounds, dimensions)
    viewport
  end

  it 'bounds' do
    expect(viewport.bounds).to eq([
      1.021728515625,
      44.574817404670306,
      15.084228515625,
      51.60437164681676
    ])
  end

  it 'center' do
    expect(viewport.center).to eq([8.054945833333333, 48.206891666666664])
  end

  it 'dimensions' do
    expect(viewport.dimensions).to eq([1280, 960])
  end

  it 'zoom' do
    expect(viewport.zoom).to eq(7)
  end
end
