# Extract Exif GPS data from sample photos, then use those to calculate new map
# bounds, zoom level and center. Also print two URLs to Mapbox, first is
# a collection of GPS points, the other represents new bounds.
#
#   Parsing Exif data (0.009919 s)
#   Found 6 photos
#   Bounds are [6.9201500000000005, 45.46555, 9.189741666666666, 50.948233333333334]
#
#   Viewport
#   #<Geo::Viewport:0x007fc3441923c8
#     @dimensions=[1280, 960],
#     @center=[8.054945833333333, 48.206891666666664],
#     @zoom=7,
#     @bounds=[1.021728515625, 44.574817404670306, 15.084228515625, 51.60437164681676]>
#
#   Mapbox Data URL:
#   http://api.tiles.mapbox.com/v4/examples.map-zr0njcqy/pin-l-0+f44(6.9558,50.941691666666664),pin-l-1+f44(6.956291666666667,50.94157777777777),pin-l-2+f44(6.9201500000000005,50.948233333333334),pin-l-3+f44(9.188316666666667,45.46555),pin-l-4+f44(9.189741666666666,45.46562222222222),pin-l-5+f44(9.185799999999999,45.46757222222222)/8.054945833333333,48.206891666666664,7/1280x960.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6IlhHVkZmaW8ifQ.hAMX5hSW-QnTeRCMAy9A8Q
#
#   Mapbox Bounds URL:
#   http://api.tiles.mapbox.com/v4/examples.map-zr0njcqy/pin-l-0+f44(1.021728515625,51.60437164681676),pin-l-1+f44(1.021728515625,48.206891666666664),pin-l-2+f44(1.021728515625,44.574817404670306),pin-l-3+f44(8.054945833333333,44.574817404670306),pin-l-4+f44(15.084228515625,44.574817404670306),pin-l-5+f44(15.084228515625,48.206891666666664),pin-l-6+f44(15.084228515625,51.60437164681676),pin-l-7+f44(8.054945833333333,51.60437164681676),pin-l-8+f44(8.054945833333333,48.206891666666664)/8.054945833333333,48.206891666666664,7/1280x960.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6IlhHVkZmaW8ifQ.hAMX5hSW-QnTeRCMAy9A8Q

require 'exifr'

$LOAD_PATH.unshift('../lib')

require 'geo'
require './helpers'

# Test photos.
photos = [
  './photos/cologne1.jpg',
  './photos/cologne2.jpg',
  './photos/cologne3.jpg',
  './photos/italy1.jpg',
  './photos/italy2.jpg',
  './photos/italy3.jpg'
]

# Extract longitude and latitude from each photo.
gps_data = exif(photos)

# Calculate the westmost, southmost, eastmost and northmost coordinates.
map_bounds = Geo::Utils.bounds(gps_data)

puts "Found #{gps_data.size} photos"
puts "Bounds are #{map_bounds}"

viewport = Geo::Viewport.new(map_bounds, [1280, 960])

puts "Viewport #{viewport.inspect}"

puts
puts 'Mapbox Data URL:'
puts data_mapbox_url(gps_data, viewport)

puts
puts 'Mapbox Bounds URL:'
puts bounds_mapbox_url(viewport)
