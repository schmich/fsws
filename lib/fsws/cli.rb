require 'rack'
require 'webrick'
require 'thor'
require 'launchy'

module Fsws
  class CommandLine < Thor
    desc '[-h|--host <host>] [-p|--port <port>] [-B|--no-browser]', 'Start server.'
    option :port, type: :numeric, aliases: :p
    option :host, type: :string, aliases: :host
    option :'no-browser', type: :boolean, aliases: :B
    option :version, type: :boolean, aliases: :v
    def start
      if options[:version]
        version
        return
      end

      browser = !options[:'no-browser']
      port = options[:port] || 9001
      interface = options[:host] || '127.0.0.1'

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
