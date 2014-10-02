require 'rack'
require 'webrick'
require 'thor'

module Fsws
  class CommandLine < Thor
    desc '[-h|--host <host>] [-p|--port <port>]', 'Start server.'
    option :port, :type => :numeric, :aliases => :p
    option :host, type: :string, aliases: :host
    option :version, type: :boolean, aliases: :v
    def start
      if options[:version]
        version
        return
      end

      port = options[:port] || 8000
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

      Rack::Handler::WEBrick.run(Fsws::server, opts)
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
