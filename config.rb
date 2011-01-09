require 'bundler'
Bundler.setup

require "jammit"
Jammit.load_configuration('assets.yml')

require 'compass'
Compass.add_project_configuration('compass.rb')

::Compass::configuration.asset_cache_buster = :none
set :haml, { :attr_wrapper => '"', :format => :html5 }

# activate :slickmap
activate :automatic_image_sizes

configure :build do
  activate :minify_css
  activate :smush_pngs
  activate :cache_buster
  activate :relative_assets
end

helpers do
  def javascripts(*packages)
    "var " +
    packages.map do |pack|
      if ENV['MM_ENV'] == 'build'
        asset_url(Jammit.asset_url(pack, :js)[1..-1])
      else
        Jammit.packager.individual_urls(pack.to_sym, :js).map do |file|
          asset_url(file.gsub(%r(^.*?build/), asset_url('')))
        end
      end
    end.flatten.map do |src|
      "s=document.createElement('script');s.src='#{src}';document.getElementsByTagName('HEAD')[0].appendChild(s)"
    end.join(';')
  end
end
