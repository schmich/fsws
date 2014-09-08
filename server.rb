require 'sinatra'
require 'pathname'

set :port, 8000
set :bind, '0.0.0.0'

mime_types = {}
File.open(File.expand_path(File.join(File.dirname(__FILE__), 'mime.types')), 'r') do |file|
  file.each_line do |line|
    if line =~ /^\s*([\w\/.-]+)\s*((\w+\s*)+);\s*$/
      mime_type = $1.strip
      extensions = $2.strip.split.map(&:strip).map(&:downcase)
      for ext in extensions
        mime_types[ext] = mime_type.downcase
      end
    end
  end
end

indexes = %w(index.html index.htm)

def allowed?(path)
  target = File.absolute_path(path)
  return target.start_with?(File.absolute_path(Dir.pwd))
end

def read(file)
  File.read(File.join(File.dirname(__FILE__), file))
end

not_found do
  erb :'404'
end

get '*' do
  path = params[:splat].first
  path = '/' if path.empty?
  path = '.' + path

  halt 404 if !allowed?(path)

  if File.file? path
    ext = File.extname(path)
    ext = ext[1...ext.length]
    mime_type = mime_types[ext] || 'text/plain'
    headers 'Content-Type' => mime_type

    return File.open(path, 'rb')
  elsif File.directory? path
    for file in indexes
      index = File.join(path, file)
      if File.file? index
        headers 'Content-Type' => 'text/html'
        return File.open(index, 'rb')
      end
    end

    if !path.end_with?('/')
      redirect to(path + '/')
    end

    pwd = Pathname.new('/' + Pathname.new(File.absolute_path(path)).relative_path_from(Pathname.new(File.absolute_path(Dir.pwd))).to_s).cleanpath
    dirs, files = Dir.entries(path).partition { |e| File.directory?(File.join(path, e)) }
    dirs.delete('.')
    dirs.sort!
    files.sort!

    erb :listing, locals: { dirs: dirs, files: files, pwd: pwd }
  else
    halt 404
  end
end
