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
  
  # fix wrong image urls
  css = File.read('build/stylesheets/cantarel.css')
  File.open('build/stylesheets/cantarel.css', 'w') do |file|
    css.gsub! '../../images', '../images'
    css.gsub! /(\.png|\.jpg)\?\d+/, '\\1'
    file.write css
  end
  Dir.glob '**/*.html' do |file|
    html = File.read(file)
    File.open(file, 'w') do |file|
      html.gsub! 'images/images', 'images'
      file.write html
    end
  end
  
  # jammit
  require "jammit"
  Jammit.load_configuration('assets.yml')
  Jammit.packager.precache_all(File.join('.', 'build', 'javascripts'), '.')
end

desc "Deploys the site to #{production_url}"
task :deploy => :build do
  puts "Deploying the site to #{production_url}"
  system("rsync -avz --delete build/ #{ssh_user}:#{production_path}")
end
