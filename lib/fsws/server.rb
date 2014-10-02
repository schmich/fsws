require 'rack'
require 'erb'
require 'pathname'
require 'ostruct'

def mime_types
  return @mime_types if @mime_types

  @mime_types = {}

  path = File.join(File.dirname(__FILE__), 'mime.types')
  File.open(path, 'r') do |file|
    file.each_line do |line|
      if line =~ /^\s*([\w\/.-]+)\s*((\w+\s*)+);\s*$/
        mime_type = $1.strip
        extensions = $2.strip.split.map(&:strip).map(&:downcase)
        for ext in extensions
          @mime_types[ext] = mime_type.downcase
        end
      end
    end
  end

  @mime_types
end

def serve(env)
  path = env['REQUEST_PATH'] || ''
  path = '/' if path.empty?
  path = '.' + path

  return error(env) if !allowed?(path)

  return serve_file(path) || serve_dir(path) || error(env)
end

def serve_file(path)
  return nil if !File.file? path

  ext = File.extname(path)
  ext = ext[1...ext.length]
  mime_type = mime_types[ext] || 'text/plain'

  return 200, { 'Content-Type' => mime_type }, File.open(path, 'rb').read
end

def serve_dir(path)
  return nil if !File.directory? path

  for file in %w(index.html index.htm)
    index = File.join(path, file)
    page = serve_file(index)
    return page if page
  end

  return redirect(path + '/') if !path.end_with?('/')

  dirs, files = Dir.entries(path).partition { |e| File.directory?(File.join(path, e)) }
  dirs.delete('.')
  dirs.delete('..') if path == './'
  dirs.sort!
  files.sort!

  pwd = Pathname.new('/' + Pathname.new(File.absolute_path(path)).relative_path_from(Pathname.new(File.absolute_path(Dir.pwd))).to_s).cleanpath

  return 200, { 'Content-Type' => 'text/html' }, erb('listing', dirs: dirs, files: files, pwd: pwd)
end

def erb(view, vars)
  ERB.new(File.read(File.join(File.dirname(__FILE__), "views/#{view}.erb")))
    .result(OpenStruct.new(vars).instance_eval { binding })
end

def error(env)
  return 404, nil, erb('404', path: env['REQUEST_PATH'])
end

def redirect(path)
  return 301, { 'Location' => path }, nil
end

def allowed?(path)
  target = File.absolute_path(path)
  return target.start_with?(File.absolute_path(Dir.pwd))
end

def include(file)
  File.read(File.join(File.dirname(__FILE__), file))
end

module Fsws
  def self.server
    Proc.new do |env|
      code, headers, body = serve(env)
      [code.to_s, headers, [body]]
    end
  end
end
