require 'rack'
require 'webrick'
require 'thor'
require 'launchy'

module Fsws
  class CommandLine < Thor
    desc '[-d <directory>] [-i <interface>] [-p <port>] [-B]', 'Start server.'
    long_desc <<-DESC
      [-d|--dir <directory>] [-i|--interface <interface>] [-p|--port <port>] [-B|--no-browser]
    DESC
    option :port, type: :numeric, aliases: :p, default: 9001, lazy_default: 9001
    option :interface, type: :string, aliases: :i, default: '127.0.0.1', lazy_default: '127.0.0.1'
    option :dir, type: :string, aliases: :d
    option :'no-browser', type: :boolean, aliases: :B
    option :version, type: :boolean, aliases: :v
    def start
      if options[:version]
        return version
      end

      puts "options = #{options}"

      dir = options[:dir]
      browser = !options[:'no-browser']
      port = options[:port]
      interface = options[:interface]

      if interface == '*'
        interface = '0.0.0.0'
      end

      if dir
        path = File.absolute_path(dir)
        if Dir.exist?(path)
          Dir.chdir(path)
        else
          $stderr.puts "Directory does not exist: #{normalize(path)}."
          exit 1
        end
      end

      if Signal.list.key? 'QUIT'
        Signal.trap('QUIT') do
          puts 'Stopping...'
          Rack::Handler::WEBrick.shutdown
        end
      end

      if Signal.list.key? 'INT'
        Signal.trap('INT') do
          puts 'Stopping...'
          Rack::Handler::WEBrick.shutdown
        end
      end

      puts ">> Serving #{normalize(Dir.pwd)}"
      puts ">> Listening on #{interface}:#{port}"
      puts ">> Ctrl+C to stop"

      rd, wr = IO.pipe
      opts = {
        BindAddress: interface,
        Port: port,
        Logger: WEBrick::Log.new(wr),
        AccessLog: []
      }

      Rack::Handler::WEBrick.run(Fsws::server, opts) do
        if browser
          Launchy.open("http://localhost:#{port}")
        end
      end
    end

    desc '-v|--version', 'Print version.'
    def version
      puts "fsws #{Fsws::VERSION}"
    end

    private

    def normalize(path)
      path.gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
    end

    default_task :start
  end
end
