lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'versify'
  spec.version       = '0.0.1'
  spec.authors       = ['Kevin Henner']
  spec.email         = ['kjhenner@gmail.com']
  spec.summary       = "Tools for the generation of poetic prose and prosodic poetry."
  spec.files         = [ 'README.md', 'Rakefile' ]
  spec.files        += Dir['{bin,lib,spec}/**/*']
  spec.executables   = ['versify']
  spec.require_paths = ['lib']
end
