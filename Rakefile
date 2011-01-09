# encoding: utf-8

require "bundler"
Bundler.setup

ssh_user = "nico@hagenburger.net"
production_url = "http://www.cantarel.net/"
production_path = "/home/web/hagenburger/PREVIEW/cantarel"

desc "Builds the site with bundler"
task :build do
  puts "Building the site"
  system "bundle exec mm-build"

  require "jammit"
  Jammit.load_configuration('assets.yml')
  Jammit.packager.precache_all(File.join('.', 'build', 'javascripts'), '.')
end

desc "Deploys the site to #{production_url}"
task :deploy => :build do
  puts "Deploying the site to #{production_url}"
  system("rsync -avz --delete build/ #{ssh_user}:#{production_path}")
end
