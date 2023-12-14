lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'core_models/version'

Gem::Specification.new do |spec|
  spec.name          = 'core_models'
  spec.version       = CoreModels::VERSION
  spec.authors       = ['Daniele Orlandi']
  spec.email         = ['daniele@orlandi.com']
  spec.summary       = %q{Core models}
  spec.description   = %q{Core models}
  spec.homepage      = 'https://yggdra.it/'
  spec.license       = 'GPL2'

  spec.files         = `git ls-files -z 2>/dev/null`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'

  spec.add_runtime_dependency 'active_rest', '>= 7.0.0'
  spec.add_runtime_dependency 'am-amqp'
  spec.add_runtime_dependency 'geocoder'
  spec.add_runtime_dependency 'vihai-password-rails'
  spec.add_runtime_dependency 'uuidtools'
  spec.add_runtime_dependency 'deep_open_struct'
  spec.add_runtime_dependency 'hooks'
  spec.add_runtime_dependency 'pg_search'
end
