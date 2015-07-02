module Geo
  # Common conversion and calculation methods.
  module Utils
    # Size of one tile. Number of tiles doubles with every zoom level.
    #
    # @return [Fixnum]
    TILE_SIZE = 256

    # The origin of the map sits at lon: 0, lat: 0 == px: 128, py: 128.
    #
    # @return [Array<Fixnum>]
    ORIGIN_PX = [
      TILE_SIZE / 2,
      TILE_SIZE / 2
    ]

    # Number of pixels in one radian.
    #
    #   PIXELS_PER_RAD.to_f # => 40.74366543152521
    #
    # @return [Rational]
    PIXELS_PER_RAD = Rational(TILE_SIZE, (2 * Math::PI))

    # Number of pixels in one degree.
    #
    #   PIXELS_PER_DEGREE.to_f # => 0.7111111111111111
    #
    # @return [Rational]
    PIXELS_PER_DEGREE = Rational(TILE_SIZE, 360)

    # Number of radians in a degree.
    #
    #   RADS_PER_DEGREE.to_f # => 0.017453292519943295
    #
    # @return [Rational]
    RADS_PER_DEGREE = Rational(Math::PI, 180)

    # Number of degrees in a radian.
    #
    #   DEGREES_PER_RAD.to_f # => 57.29577951308232
    #
    # @return [Rational]
    DEGREES_PER_RAD = Rational(180, Math::PI)

    module_function

    ########################
    # Coordinates conversion
    ########################

    # Turn +[lon, lat]+ GPS coords into +[px, px]+ pixel coords on mercator map.
    #
    #   pixel_coord(6.916236877441406, 50.95788608634216, 0)
    #   # => [132, 85]
    #   pixel_coord(6.916236877441406, 50.95788608634216, 15)
    #   # => [4355464, 2809876]
    #
    # @param lon_deg [Float]  GPS longitude.
    # @param lat_deg [Float]  GPS latitude.
    # @param zoom    [Fixnum] Map zoom level.
    #
    # @return [Array<Fixnum>]
    def pixel_coord(lon_deg, lat_deg, zoom)
      wx, wy      = ll_to_world_coord(lon_deg, lat_deg)
      tiles_count = tiles_count_at(zoom)

      px = wx * tiles_count
      py = wy * tiles_count

      [px.to_i, py.to_i]
    end

    # Turn +[px, px]+ pixel coords on mercator map into +[lon, lat]+ GPS coords.
    #
    #   ll_coord(128, 128, 0)
    #   # => [0.0, 0.0]
    #   ll_coord(4355464, 2809876, 15)
    #   # => [6.916236877441406, 50.95788608634216]
    #
    # @param px   [Fixnum] X px position on the mercator map.
    # @param py   [Fixnum] Y px position on the mercator map.
    # @param zoom [Fixnum] Zoom level.
    #
    # @return [Array<Float>]
    def ll_coord(px, py, zoom)
      wx, wy = px_to_world_coord(px, py, zoom)

      lon = (wx - ORIGIN_PX.first) / PIXELS_PER_DEGREE
      wtf = Rational(wy - ORIGIN_PX.last, -PIXELS_PER_RAD)
      lat = DEGREES_PER_RAD * magic(wtf)

      [lon.to_f, lat.to_f]
    end

    # Turn +[lon, lat]+ GPS coords into +[px, px]+ pixel coords on mercator map
    # as if the zoom was 0 (the whole world is one one tile 256x256 px).
    #
    #   ll_to_world_coord(0, 0)
    #   # => [128.0, 128.0]
    #   ll_to_world_coord(6.916236877441406, 50.95788608634216)
    #   # => [132.918212890625, 85.7506103515625]
    #
    # @param lon_deg [Float]
    # @param lat_deg [Float]
    #
    # @return [Array<Float>]
    def ll_to_world_coord(lon_deg, lat_deg)
      wx = ORIGIN_PX.first + PIXELS_PER_RAD * lon_deg_to_rad(lon_deg)
      wy = ORIGIN_PX.last - PIXELS_PER_RAD * lat_deg_to_rad_scaled(lat_deg)

      [wx.to_f, wy.to_f]
    end

    # Turn +[px, px]+ pixel coords at given zoom into +[px, px]+ pixel coords at
    # zoom 0 (the whole world is one one tile 256x256 px).
    #
    #   px_to_world_coord(128, 128, 0)
    #   # => [128.0, 128.0]
    #   px_to_world_coord(4355464, 2809876, 15)
    #   # => [132.918212890625, 85.7506103515625]
    #
    # @param px   [Fixnum] X px position on the mercator map.
    # @param py   [Fixnum] Y px position on the mercator map.
    # @param zoom [Fixnum] Zoom level.
    #
    # @return [Array<Float>]
    def px_to_world_coord(px, py, zoom)
      tiles_count = tiles_count_at(zoom)

      wx = px.to_f / tiles_count
      wy = py.to_f / tiles_count

      [wx, wy]
    end

    ############
    # Utilitiles
    ############

    # Convert longitude in degrees to radians.
    #
    # @param lon_deg [Float]
    #
    # @return [Float]
    def lon_deg_to_rad(lon_deg)
      lon_deg * RADS_PER_DEGREE
    end

    # Convert latitude in degrees to radians.
    #
    # @param lat_deg [Float]
    #
    # @return [Float]
    def lat_deg_to_rad(lat_deg)
      lat_deg * RADS_PER_DEGREE
    end

    # Convert latitude in degrees to radians using Mercator projection
    # derivation.
    # http://en.wikipedia.org/wiki/Mercator_projection#Derivation_of_the_Mercator_projection
    #
    # @param lat_deg [Float]
    #
    # @return [Float]
    def lat_deg_to_rad_scaled(lat_deg)
      lat_rad = lat_deg_to_rad(lat_deg)

      Math.log(
        Math.tan(
          Rational(Math::PI, 4) + Rational(lat_rad, 2)
        )
      )
    end

    # No idea what this is doing.
    #
    # @param huh [Rational] No idea what this is
    #
    # @return [Rational]
    def magic(huh)
      2 * Math.atan(Math.exp(huh)) - Rational(Math::PI, 2)
    end

    # Calculate number of tiles on mercator map with certain zoom level.
    #
    #   tiles_count_at(0) # => 1
    #   tiles_count_at(1) # => 2
    #   tiles_count_at(2) # => 4
    #   tiles_count_at(3) # => 8
    #   tiles_count_at(4) # => 16
    #
    # @param zoom [Fixnum] Map zoom level.
    #
    # @return [Fixnum]
    def tiles_count_at(zoom)
      2**zoom
    end

    # Find map bounds from an array of GPS points.
    #
    # An array of +[lon, lat]+ arrays is expected but not mandatory if block is
    # passed. The block must return said array.
    #
    # @param points [Array<Array>] Array of GPS coords, eg. +[[lon, lat], ...]+
    # @yieldreturn  [Array<Float>] Block is expected to return +[[lon, lat], ...]+.
    #
    # @return [Array<Float>]
    def bounds(points, &block)
      points = points.map { |p| block.call(p) } if block

      [
        westmost_longitude(points),
        southmost_latitude(points),
        eastmost_longitude(points),
        northmost_latitude(points)
      ]
    end

    # Find the westmost longitude amongst an array of GPS points.
    #
    # @param points [Array<Array>] Array of GPS coords, eg. +[[lon, lat], ...]+
    #
    # @return [Float]
    def westmost_longitude(points)
      points.map { |p| p[0] }.min
    end

    # Find the eastmost longitude amongst an array of GPS points.
    #
    # @param points [Array<Array>] Array of GPS coords, eg. +[[lon, lat], ...]+
    #
    # @return [Float]
    def eastmost_longitude(points)
      points.map { |p| p[0] }.max
    end

    # Find the northmost latitude amongst an array of GPS points.
    #
    # @param points [Array<Array>] Array of GPS coords, eg. +[[lon, lat], ...]+
    #
    # @return [Float]
    def northmost_latitude(points)
      points.map { |p| p[1] }.max
    end

    # Find the shouthmost latitude amongst an array of GPS points.
    #
    # @param points [Array<Array>] Array of GPS coords, eg. +[[lon, lat], ...]+
    #
    # @return [Float]
    def southmost_latitude(points)
      points.map { |p| p[1] }.min
    end
  end
end
