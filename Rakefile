# encoding: utf-8

require "bundler"
Bundler.setup

desc "Builds the site with bundler"
task :build do
  puts "Building the site"
  system "bundle exec middleman build"

  # fix wrong image urls
  css = File.read('build/stylesheets/cantarel.css')
  File.open('build/stylesheets/cantarel.css', 'w') do |file|
    css.gsub! '@charset "ASCII-8BIT";', ''
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
end

desc "Deploys the site to www.cantarel.de"
task :deploy => :build do
  require 'net/ssh'
  require 'net/sftp'

  password    = File.read('.password').strip
  lastdeploy  = Time.parse(File.read('.lastdeploy'))
  server      = 'www.cantarel.de'
  user        = 'u43028714'
  server_path = '/hp2011'

  puts "Deploying the site to #{server}"
  Net::SFTP.start server, user, :password => password do |session|
    Dir.glob('build/**/*.*') do |file|
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
  dir = 'source/blog'
  FileUtils.mkdir dir unless File.exists?(dir)
  filename = "#{dir}/#{time.to_s[0...10]}-#{slug}.html.rmd"

  File.open filename, 'w' do |file|
    file.write <<-MARKDOWN.gsub(/^      /, '')
      ---
      description: "Insert description here (80 to 160 characters)"
      title:       "#{title}"
      thumb:       "blog/thumbs/insert-filename-here.jpg"
      ---

      #{title}
      #{'=' * title.length}

      Write some nice stuff here.

    MARKDOWN
  end

  puts "Created blog post “#{title}” at #{filename}"
  `mate #{filename}`
end
