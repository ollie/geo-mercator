# Geo [![Build Status](https://img.shields.io/travis/ollie/geo/master.svg)](https://travis-ci.org/ollie/geo) [![Code Climate](https://img.shields.io/codeclimate/github/ollie/geo.svg)](https://codeclimate.com/github/ollie/geo)

This is just a tiny library (actually a gem but not published on rubygems.org)
which abstracts away working with GPS points and bounds on the Mercator map.

It was created because I wanted to give [Mapbox][mapbox_url] a set of
GPS (lat/lon) points and it would return a properly centered and zoomed in
static map. Except that it doesn't do that.

So I crawled around the web and composed all I needed from those three
libraries:

* [geo-viewport][geo-viewport_url] Node.js package,
* [node-sphericalmercator][node-sphericalmercator_url] Node.js package,
* and [Simple Mercator Location][simple-mercator-location_url] Ruby gem.

None of them do all I needed and some of them are really cryptic.
It seems to work properly but if you find a bug, please let me know.

## What does it do?

The `Geo::Viewport` class initializer expects map bounds array (WSEN: westmost,
southmost, eastmost and northmost coordinates) and an array of mercator map
dimensions in pixels. It than calculates the center, the zoom level and a new
set of bounds for given dimensions. Why new bounds? Because zoom level
is a whole number so the map bounds are expanded a bit to reflect that.
The instance methods are used to get those properties.

The `Geo::Utils` module is a place for all kinds of conversion methods but
there is one externally useful: the `bounds` method. It expects an array of
GPS points and returns a `[w, s, e, n]` map bounds array which then can
be fed into the initializer.

## Usage

See examples, too.

```ruby
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

map_bounds          # => [6.9201500000000005, 45.46555, 9.189741666666666, 50.948233333333334]
viewport.bounds     # => [1.021728515625, 44.574817404670306, 15.084228515625, 51.60437164681676]
viewport.dimensions # => [1280, 960]
viewport.width      # => 1280
viewport.height     # => 960
viewport.center     # => [8.054945833333333, 48.206891666666664]
viewport.center_lon # => 8.054945833333333
viewport.center_lat # => 48.206891666666664
viewport.zoom       # => 7
```

## Running examples

One of the examples uses Gnuplot. If you are on OS X and you use Homebrew,
you may need to install it via `brew install gnuplot --with-x`.
Also check the dependecy gems like `k_means_pp` and `exifr`.

    $ cd examples
    $ ruby simple.rb
    $ ruby mapbox.rb
    $ ruby mapbox_with_clusters.rb

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'geo', git: 'https://github.com/ollie/geo-mercator.git'
```

And then execute:

    $ bundle

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

1. Fork it (https://github.com/ollie/geo-mercator/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[mapbox_url]:                   https://www.mapbox.com/developers/api/
[geo-viewport_url]:             https://github.com/mapbox/geo-viewport
[node-sphericalmercator_url]:   https://github.com/mapbox/node-sphericalmercator
[simple-mercator-location_url]: https://github.com/romanlehnert/simple_mercator_location
