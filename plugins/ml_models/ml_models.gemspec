lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ml_models/version'

Gem::Specification.new do |spec|
  spec.name          = 'ml_models'
  spec.version       = MlModels::VERSION
  spec.authors       = ['Daniele Orlandi']
  spec.email         = ['daniele@orlandi.com']
  spec.summary       = %q{Mailing List Manager}
  spec.description   = %q{Mailing List Manager}
  spec.homepage      = 'https://yggdra.it/'
  spec.license       = 'GPL2'

  spec.files         = `git ls-files -z 2>/dev/null`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'

  spec.add_runtime_dependency 'active_rest', '>= 6.6.0'
  spec.add_runtime_dependency 'dkim'
  spec.add_runtime_dependency 'mail'
  spec.add_runtime_dependency 'am-smtp'
  spec.add_runtime_dependency 'am-http'
end
