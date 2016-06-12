# encoding: utf-8

require "bundler"
Bundler.setup

desc "Deploys the site to www.cantarel.de"
task :deploy => :build do
  require 'net/ssh'
  require 'net/sftp'
  require 'time'

  password    = File.read('.password').strip
  lastdeploy  = Time.parse(File.read('.lastdeploy'))
  server      = 'www.cantarel.de'
  user        = 'u43028714'
  server_path = '/hp2011'

  puts "Deploying the site to #{server}"
  Net::SFTP.start server, user, :password => password do |session|
    Dir.glob('public/**/*.*') do |file|
      if File.ctime(file) > lastdeploy
        server_file = file.gsub(/^build/, server_path)
        puts "Uploading #{file} to #{server}#{server_file}"
        session.upload! file, server_file
      end
    end
  end

  File.open '.lastdeploy', 'w' do |file|
    file.write Time.now
  end
end
