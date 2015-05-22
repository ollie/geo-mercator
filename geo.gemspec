# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'geo/version'

Gem::Specification.new do |spec|
  spec.name          = 'geo'
  spec.version       = Geo::VERSION
  spec.authors       = ['Oldrich Vetesnik']
  spec.email         = ['oldrich.vetesnik@gmail.com']

  spec.summary       = 'GPS points to Mercator map calculator.'
  spec.description   = 'This is just a tiny library which abstracts away ' \
                       'working with GPS points and bounds on the Mercator map.'
  spec.homepage      = 'https://github.com/ollie/geo-mercator'
  spec.license       = 'MIT'

  # rubocop:disable Metrics/LineLength
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # System
  spec.add_development_dependency 'bundler', '~> 1.7'

  # Test
  spec.add_development_dependency 'rspec',     '~> 3.2'
  spec.add_development_dependency 'simplecov', '~> 0.10'

  # Code style, debugging, docs
  spec.add_development_dependency 'rubocop', '~> 0.31'
  spec.add_development_dependency 'pry',     '~> 0.10'
  spec.add_development_dependency 'yard',    '~> 0.8'
  spec.add_development_dependency 'rake',    '~> 10.4'
  # spec.add_development_dependency 'gnuplot', '~> 2.6'

  # EXIF Reader is a module to read EXIF from JPEG and TIFF images.
  spec.add_development_dependency 'exifr', '~> 1.2'

  # This is a Ruby implementation of the k-means++ algorithm for data
  # clustering. In other words: Grouping a bunch of X, Y points into K groups.
  spec.add_development_dependency 'k_means_pp', '~> 0.0'
end
