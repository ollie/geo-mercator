# For a bunch of GPS points calculate new map bounds, zoom level and center.
#
#   Map bounds before recalculation: [6.9201500000000005, 45.46555, 9.189741666666666, 50.948233333333334]
#   Map bounds after recalculation:  [1.021728515625, 44.574817404670306, 15.084228515625, 51.60437164681676]
#   Map dimensions in pixels:        [1280, 960]
#   Map center in lon/lat:           [8.054945833333333, 48.206891666666664]
#   Map zoom level:                  7

require 'k_means_pp'

$LOAD_PATH.unshift('../lib')

require 'geo'

# Photos longitude and latitude.
gps_data = [
  [6.9558,             50.941691666666664],
  [6.956291666666667,  50.94157777777777],
  [6.9201500000000005, 50.948233333333334],
  [9.188316666666667,  45.46555],
  [9.189741666666666,  45.46562222222222],
  [9.185799999999999,  45.46757222222222]
]

# Calculate the westmost, southmost, eastmost and northmost coordinates.
map_bounds = Geo::Utils.bounds(gps_data)
dimensions = [1280, 960]
viewport   = Geo::Viewport.new(map_bounds, dimensions)

puts "Map bounds before recalculation: #{ map_bounds }"
puts "Map bounds after recalculation:  #{ viewport.bounds }"
puts "Map dimensions in pixels:        #{ viewport.dimensions }"
puts "Map width in pixels:             #{ viewport.width }"
puts "Map height in pixels:            #{ viewport.height }"
puts "Map center in lon/lat:           #{ viewport.center }"
puts "Map center longitude:            #{ viewport.center_lon }"
puts "Map center latitude:             #{ viewport.center_lat }"
puts "Map zoom level:                  #{ viewport.zoom }"
