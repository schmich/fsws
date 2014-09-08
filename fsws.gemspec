require File.expand_path('lib/fsws/version.rb', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name = 'fsws'
  s.version = Fsws::VERSION
  s.executables << 'fsws'
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'Ruby file system web server. '
  s.description = <<-END
    A simple Ruby-based file system web server for serving
    static files out of a directory.
  END
  s.authors = ['Chris Schmich']
  s.email = 'schmch@gmail.com'
  s.files = Dir['{lib}/**/*', 'bin/*', '*.md', 'LICENSE']
  s.require_path = 'lib'
  s.homepage = 'https://github.com/schmich/fsws'
  s.license = 'MIT'
  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency 'rack', '~> 1.5'
  s.add_development_dependency 'rake', '~> 10.3'
end
