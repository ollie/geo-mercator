# Monkey patching!
class Float
  # Turn a point into a range of points with given distance.
  #
  #   15.5.within(0.5) # => 15.0..16.0
  #
  # @param deviation [Float]
  #
  # @return [Range]
  def within(deviation)
    (self - deviation)..(self + deviation)
  end
end

# Measure how long the block executes and return whatever it returned.
#
# @param heading [String]
def measure(heading)
  start_time = Time.now
  print heading
  result = yield
  end_time = Time.now - start_time
  puts " (#{end_time} s)"
  result
end

# Take an array of image paths and return an array of GPS locations.
#
# @param paths [Array<String>]
#
# @return [Array<Array<Float>>]
def exif(paths)
  measure 'Parsing Exif data' do
    gps = paths.map do |path|
      gps = EXIFR::JPEG.new(path).gps
      next unless gps
      # puts "#{ File.basename(path) }: #{ gps.latitude } #{ gps.longitude }"
      [gps.longitude, gps.latitude]
    end

    gps.compact
  end
end

# Filter locations in Hradec Kralove.
#
# @param points [Array<Array<Float>>]
#
# @return [Array<Array<Float>>]
def filter_locations_hk(points)
  filter_locations(points, 15.845.within(0.07), 50.21.within(0.1))
end

# Filter locations in Trutnov.
#
# @param points [Array<Array<Float>>]
#
# @return [Array<Array<Float>>]
def filter_locations_tu(points)
  filter_locations(points, 15.9.within(0.07), 50.57.within(0.1))
end

# Filter locations in Babiccino Udoli.
#
# @param points [Array<Array<Float>>]
#
# @return [Array<Array<Float>>]
def filter_locations_bu(points)
  filter_locations(points, 16.06.within(0.07), 50.41.within(0.1))
end

# Filter locations by specific longitude and latitude ranges.
#
# @param points        [Array<Array<Float>>]
# @param lon_deg_range [Range]
# @param lat_deg_range [Range]
#
# @return [Array<Array<Float>>]
def filter_locations(points, lon_deg_range, lat_deg_range)
  points.select do |p|
    lon_deg_range.include?(p[0]) && lat_deg_range.include?(p[1])
  end
end

# Plot and display data on the screen.
#
# @param clusters       [Array<Cluster>]
# @param show_centroids [Bool]
def plot(clusters, show_centroids = true)
  # Graph output by running gnuplot pipe
  Gnuplot.open do |gp|
    # Start a new plot
    Gnuplot::Plot.new(gp) do |plot|
      # Plot each cluster's points
      clusters.each do |cluster|
        # Collect all x and y coords for this cluster
        x = cluster.points.map { |p| p[0] }
        y = cluster.points.map { |p| p[1] }

        # Plot w/o a title (clutters things up)
        plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
          ds.notitle
        end

        next unless show_centroids

        # Centroid point as bigger black points
        x = [cluster.centroid.x]
        y = [cluster.centroid.y]

        plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
          ds.notitle
          ds.linecolor = '000000'
          ds.linewidth = 3
        end
      end
    end
  end
end

# Show all data points on the Mapbox map.
#
# @param data     [Array<Array<Float>>]
# @param viewport [Geo::Viewport]
#
# @return [String]
def data_mapbox_url(data, viewport)
  mapbox_url(data, viewport)
end

# Show all cluster centroids on the Mapbox map.
#
# @param clusters [Array<KMeansPP::Cluster]
# @param viewport [Geo::Viewport]
#
# @return [String]
def centroids_mapbox_url(clusters, viewport)
  data = clusters.map(&:centroid).map { |p| [p.x, p.y] }
  mapbox_url(data, viewport)
end

# Show the viewport bounds on the Mapbox map.
#
# @param viewport [Geo::Viewport]
#
# @return [String]
def bounds_mapbox_url(viewport)
  w, s, e, n   = viewport.bounds
  c_lon, c_lat = viewport.center
  data         = [
    [w, n],
    [w, c_lat],
    [w, s],
    [c_lon, s],
    [e, s],
    [e, c_lat],
    [e, n],
    [c_lon, n],
    [c_lon, c_lat]
  ]

  mapbox_url(data, viewport)
end

# Generic method for showing markers on the Mapbox map.
#
# @param markers  [Array<Array<Float>>]
# @param viewport [Geo::Viewport]
#
# @return [String]
def mapbox_url(markers, viewport)
  markers = markers.map.with_index do |p, i|
    "pin-l-#{i}+f44(#{p[0]},#{p[1]})"
  end.join(',')

  "http://api.tiles.mapbox.com/v4/examples.map-zr0njcqy/#{markers}/" \
  "#{viewport.center[0]},#{viewport.center[1]},#{viewport.zoom}/" \
  "#{viewport.dimensions[0]}x#{viewport.dimensions[1]}.png?access_token=" \
  'pk.eyJ1IjoibWFwYm94IiwiYSI6IlhHVkZmaW8ifQ.hAMX5hSW-QnTeRCMAy9A8Q'
end
