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
  Dir.glob '**/*.php' do |file|
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

desc "Creates a new blog post"
task :blog_post, [:title] do |t, args|
  title = args.title

  slug = title.downcase
  { 'ä' => 'ae', 'ö' => 'oe', 'ü' => 'ue', 'ß' => 'ss' }.each do |a, b|
    slug.gsub! a, b
  end
  slug.gsub! /[^a-z0-9]/, '-'
  slug.gsub! /--+/, '-'
  slug.gsub! /^-|-$/, ''
  
  time = Time.now
  dir = 'views/blog'
  FileUtils.mkdir dir unless File.exists?(dir)
  filename = "#{dir}/#{slug}.html.rmd"
  
  File.open filename, 'w' do |file|
    file.write <<-MARKDOWN.gsub(/^      /, '')
      <%
        @date = Time.mktime(#{time.year}, #{time.month}, #{time.day})
        @description = 'Insert description here (80 to 160 characters)'
        @title = '#{title}'
      %>
      
      #{title}
      #{'=' * title.length}
      
      Write some nice stuff here.
      
    MARKDOWN
  end
  
  puts "Created blog post “#{title}” at #{filename}"
  `mate #{filename}`
end