# frozen_string_literal: true

require 'net/ftp'
require 'logger'

IP_FILE = __dir__ + '/list_ip.txt'
LOG_FILE = 'sprut.log'
CONTENT_SERVER_FTP_LOGIN = 'sprut'
CONTENT_SERVER_FTP_PASSWORD = 'sprut'

LOGGER = Logger.new(LOG_FILE, 'monthly')

def make_command_file
  # Отнимаю от времени 3 часа, так как спрут принимает время по меридиану
  now = Time.now - 180 * 60
  file = File.open(__dir__ + '/command.txt', 'w')
  file.puts "time #{now.strftime('%d.%m.%Y %T')}"
  file.close
  file
end

def update_time(host_ip)
  LOGGER.info "Connect to ftp://#{CONTENT_SERVER_FTP_LOGIN}@#{host_ip}"
  begin
    Net::FTP.open(host_ip, CONTENT_SERVER_FTP_LOGIN, CONTENT_SERVER_FTP_PASSWORD) do |ftp|
      ftp.putbinaryfile(make_command_file)
      LOGGER.info "Upload file command.txt to #{host_ip}"
    end
  rescue SocketError
    LOGGER.error "SocketError connection to ftp://#{CONTENT_SERVER_FTP_LOGIN}@#{host_ip}"
  rescue Net::ReadTimeout => e
    LOGGER.error e.message
  end
end

if __FILE__ == $PROGRAM_NAME
  File.open(IP_FILE) do |f|
    f.each_line { |ip| update_time ip.sub(/\s/, '') }
  end
end
