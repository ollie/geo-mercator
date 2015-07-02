# Extract Exif GPS data from all of your photos, cluster them and then use the
# centroids to calculate new map bounds, zoom level and center.
# Print two URLs to Mapbox, first is a collection of GPS points, the other
# represents new bounds. Also display a plot of all the data via Gnuplot.
#
#   Loading photos (0.007299 s)
#   Parsing Exif data (1.960344 s)
#   Found 379 photos
#   Bounds are [15.632366666666666, 49.850236111111116, 16.108872222222224, 50.573033333333335]
#   Calculating viewport (0.000112 s)
#   Viewport
#   #<Geo::Viewport:0x007ff87905e9d8
#     @dimensions=[1280, 960],
#     @center=[15.870619444444445, 50.21163472222223],
#     @zoom=10,
#     @bounds=[14.9908447265625, 49.78835749241399, 16.7486572265625, 50.63204218884234]>
#   Clustering data (0.007476 s)
#
#   Mapbox Centroids URL:
#   http://api.tiles.mapbox.com/v4/examples.map-zr0njcqy/pin-l-0+f44(15.838781175213676,50.20487181623928),pin-l-1+f44(15.904240050505058,50.56492914141413),pin-l-2+f44(16.108517512077302,49.85044782608695),pin-l-3+f44(16.053686036036037,50.4158554054054),pin-l-4+f44(15.632622916666666,50.36821875)/15.870619444444445,50.21163472222223,10/1280x960.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6IlhHVkZmaW8ifQ.hAMX5hSW-QnTeRCMAy9A8Q
#
#   Mapbox Bounds URL:
#   http://api.tiles.mapbox.com/v4/examples.map-zr0njcqy/pin-l-0+f44(14.9908447265625,50.63204218884234),pin-l-1+f44(14.9908447265625,50.21163472222223),pin-l-2+f44(14.9908447265625,49.78835749241399),pin-l-3+f44(15.870619444444445,49.78835749241399),pin-l-4+f44(16.7486572265625,49.78835749241399),pin-l-5+f44(16.7486572265625,50.21163472222223),pin-l-6+f44(16.7486572265625,50.63204218884234),pin-l-7+f44(15.870619444444445,50.63204218884234),pin-l-8+f44(15.870619444444445,50.21163472222223)/15.870619444444445,50.21163472222223,10/1280x960.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6IlhHVkZmaW8ifQ.hAMX5hSW-QnTeRCMAy9A8Q

require 'exifr'
require 'k_means_pp'
require 'gnuplot'

$LOAD_PATH.unshift('../lib')

require 'geo'
require './helpers'

# Real photos in the ~/Pictures/Phone directory.
# Change it to point to your directory full of pictures.
photos = measure 'Loading photos' do
  Dir[File.expand_path('~/Pictures/Phone/**/*.jpg')]
end

# Extract longitude and latitude from each photo.
gps_data = exif(photos)

# And even filter them by specific bounds.
# gps_data = filter_locations_hk(gps_data)

# Calculate the westmost, southmost, eastmost and northmost coordinates.
map_bounds = Geo::Utils.bounds(gps_data)

puts "Found #{gps_data.size} photos"
puts "Bounds are #{map_bounds}"

viewport = measure 'Calculating viewport' do
  Geo::Viewport.new(map_bounds, [1280, 960])
end

puts "Viewport #{viewport.inspect}"

# We want 5 groups.
clusters = measure 'Clustering data' do
  KMeansPP.clusters(gps_data, 5)
end

puts
puts 'Mapbox Centroids URL:'
puts centroids_mapbox_url(clusters, viewport)

puts
puts 'Mapbox Bounds URL:'
puts bounds_mapbox_url(viewport)

plot clusters
