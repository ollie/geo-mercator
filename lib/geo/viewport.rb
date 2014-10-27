# Wrapper module for other modules.
module Geo
  # Calculate latitude and longitude center and zoom level for a set of bounds.
  #
  # Inspired from:
  #
  # * from https://github.com/mapbox/geo-viewport
  # * https://github.com/mapbox/node-sphericalmercator
  # * https://github.com/romanlehnert/simple_mercator_location
  #
  # Usage:
  #
  #   # Photos longitude and latitude.
  #   gps_data = [
  #     [6.9558,             50.941691666666664],
  #     [6.956291666666667,  50.94157777777777],
  #     [6.9201500000000005, 50.948233333333334],
  #     [9.188316666666667,  45.46555],
  #     [9.189741666666666,  45.46562222222222],
  #     [9.185799999999999,  45.46757222222222]
  #   ]
  #
  #   # Calculate the westmost, southmost, eastmost and northmost coordinates.
  #   map_bounds = Geo::Utils.bounds(gps_data)
  #   dimensions = [1280, 960]
  #   viewport   = Geo::Viewport.new(map_bounds, dimensions)
  #
  #   map_bounds          # => [6.9201500000000005, 45.46555, 9.189741666666666, 50.948233333333334]
  #   viewport.bounds     # => [1.021728515625, 44.574817404670306, 15.084228515625, 51.60437164681676]
  #   viewport.dimensions # => [1280, 960]
  #   viewport.center     # => [8.054945833333333, 48.206891666666664]
  #   viewport.zoom       # => 7
  class Viewport
    # Pixel dimensions of the map.
    #
    # @return [Array<Fixnum>]
    attr_reader :dimensions

    # Calculated center of the bounds in +[lon, lat]+ GPS coords.
    #
    # @return [Array<Float>]
    attr_reader :center

    # Calculated zoom level.
    #
    # @return [Fixnum]
    attr_reader :zoom

    # New bounds in respect to new center and zoom.
    #
    # @return [Array<Float>]
    attr_reader :bounds

    # Calculate center and zoom level for map bounds.
    #
    #   viewport = Geo::Viewport.new([
    #     5.668343999999995,  # Longitude
    #     45.111511000000014, # Latitude
    #     5.852471999999996,  # Longitude
    #     45.26800200000002   # Latitude
    #   ], [640, 480])
    #
    #   viewport.center # => [5.7604079999999955, 45.189756500000016]
    #   viewport.zoom   # => 11
    #
    # @param bounds     [Array<Float>]  Map bounds as +[w, s, e, n]+ float
    #                                   array.
    # @param dimensions [Array<Fixnum>] Map pixel dimensions as
    #                                   +[width, height]+ px array.
    # @param min_zoom   [Fixnum]        Minimal zoom, default +0+.
    # @param max_zoom   [Fixnum]        Maximal zoom, default +20+.
    def initialize(bounds, dimensions, min_zoom = 0, max_zoom = 20)
      @dimensions = dimensions
      @center     = calculate_center(*bounds)
      @zoom       = calculate_zoom(bounds, dimensions, min_zoom, max_zoom)
      @bounds     = calculate_new_bounds(dimensions)
    end

    # Calculate the map bounds center in +[lon, lat]+ GPS coords.
    #
    # @param w [Float] Westmost longitude.
    # @param s [Float] Southmost latitude.
    # @param e [Float] Eastmost longitude.
    # @param n [Float] Northmost latitude.
    #
    # @return [Array<Float>] New center GPS location.
    def calculate_center(w, s, e, n)
      center_lon = (w + e) / 2.0
      center_lat = (s + n) / 2.0
      center     = [center_lon, center_lat]
      center
    end

    # Calculate map zoom level.
    #
    # @param bounds     [Array<Float>]  Map bounds as +[w, s, e, n]+ float
    #                                   array.
    # @param dimensions [Array<Fixnum>] Map pixel dimensions as
    #                                   +[width, height]+ px array.
    # @param min_zoom   [Fixnum]        Minimal zoom.
    # @param max_zoom   [Fixnum]        Maximal zoom.
    #
    # @return [Fixnum] New zoom level.
    def calculate_zoom(bounds, dimensions, min_zoom, max_zoom)
      base           = max_zoom
      bottom_left_px = Utils.pixel_coord(bounds[0], bounds[1], base)
      top_right_px   = Utils.pixel_coord(bounds[2], bounds[3], base)
      width          = top_right_px[0] - bottom_left_px[0]
      height         = bottom_left_px[1] - top_right_px[1]
      ratios         = [width.to_f / dimensions[0], height.to_f / dimensions[1]]
      adjusted       = [
        base - (Math.log(ratios[0]) / Math.log(2)),
        base - (Math.log(ratios[1]) / Math.log(2))
      ].min.floor
      zoom           = [min_zoom, [max_zoom, adjusted].min].max
      zoom
    end

    # Calculate new bounds from new center and zoom as +[w, s, e, n]+ float
    # array.
    #
    # @param dimensions [Array<Fixnum>] Map pixel dimensions as
    #                                   +[width, height]+ px array.
    #
    # @return [Array<Float>] New bounds.
    def calculate_new_bounds(dimensions)
      px = Utils.pixel_coord(@center[0], @center[1], zoom)

      top_left_px = [
        px[0] - (dimensions[0] / 2),
        px[1] - (dimensions[1] / 2)
      ]
      bottom_right_px = [
        px[0] + (dimensions[0] / 2),
        px[1] + (dimensions[1] / 2)
      ]

      top_left_ll     = Utils.ll_coord(top_left_px[0], top_left_px[1], zoom)
      bottom_right_ll = Utils.ll_coord(bottom_right_px[0], bottom_right_px[1], zoom)

      bounds = [
        top_left_ll[0],
        bottom_right_ll[1],
        bottom_right_ll[0],
        top_left_ll[1]
      ]

      bounds
    end
  end
end
