require 'bundler'
Bundler.setup

require "jammit"
Jammit.load_configuration('assets.yml')

require 'compass'
Compass.add_project_configuration('compass.rb')

::Compass::configuration.asset_cache_buster = :none
set :haml, { :attr_wrapper => '"', :format => :html5 }

page '/blog/*', :layout_engine => :erb

# activate :slickmap
activate :automatic_image_sizes

configure :build do
  activate :minify_css
  activate :smush_pngs
  activate :cache_buster
  activate :relative_assets
end

require File.join(Dir.getwd, 'helpers', 'blog_helper')
helpers do
  include BlogHelper

  def javascripts(*packages)
    packages.map do |pack|
      if ENV['MM_ENV'] == 'build'
        asset_url(Jammit.asset_url(pack, :js)[1..-1])
      else
        Jammit.packager.individual_urls(pack.to_sym, :js).map do |file|
          asset_url(file.gsub(%r(^.*?build/), asset_url('')))
        end
      end
    end.flatten.map do |src|
      %Q(<script src="#{src}"></script>)
    end.join("\n    ")
  end
  
  def portfolio_thumb(src, title = nil, options = {})
    request.env['REQUEST_URI'] =~ %r(^/([\w_-]+))
    request.route =~ %r(^/([\w_-]+))
    view = $1
    thumb = "#{view}/thumbs/#{src}";
    if src =~ /\.(mov)$/
      options[:class] = 'quicktime';
      thumb.gsub! '.mov', '.jpg'
    end
    if title
      options[:title] = title
    end
    link_to(image_tag(thumb), "images/#{view}/#{src}", options)
  end
end

require 'tilt'
require 'erb'
require 'compass'
module ::Tilt
  class MdErbTemplate < RDiscountTemplate
    def prepare
      @outvar = options[:outvar] || self.class.default_output_variable
      @data = data
      @data = @data.force_encoding("UTF-8")
    end

    def evaluate(scope, locals, &block)
      # filter CSS and JavaScript
      @data.gsub! %r(^<style type="text/s?css">(.+?)</style>$)m do
        css = %Q(@import "compass"; #{$1})
        sass_options = Compass.sass_engine_options
        sass_options.merge! :syntax => :scss, :style => :compressed
        css = Sass::Engine.new(css, sass_options).render
        scope.instance_eval("@css ||= ''\n@css << %q(#{css})", eval_file, 1)
        ''
      end
      @data.gsub! %r(^<script>(.+?)</script>$)m do
        javascript = $1
        scope.instance_eval("@javascript ||= ''\n@javascript << %q(#{javascript})", eval_file, 1)
        ''
      end

      erb = ::ERB.new(@data, options[:safe], options[:trim], @outvar).src
      md = scope.instance_eval(erb, eval_file, 1)
      # Maruku’s HTML parser is a bad idea.
      # md = Maruku.new(md).to_html
      md = RDiscount.new(md)
      md.filter_html = false
      md.filter_styles = false
      html = md.to_html
      
      # allow <dl>s (not implemented in RDiscount)
      html.gsub! %r(<p>(.+?)\n:\s+(.+?)</p>), "  <dt>\\1</dt>\n  <dd>\\2</dd>"
      html.gsub! %r((</(p|div|figure|h1|h2|table|pre)>\n+)  <dt>)m, "\\1<dl>\n  <dt>"
      html.gsub! %r(</dd>\n\n<)m, "</dd>\n</dl>\n<"

      # remove uglyness and create beautiful HTML5
      html.gsub! %r(<p><figure), '<figure'
      html.gsub! %r(</figure></p>), '</figure>'
      html.gsub! /\n\n/, "\n"
      html.gsub! /([^>])\n/, '\\1 '
      html.gsub! /<h2 id='_?(.+?)_?'>(.+?)<\/h2>/ do
        text = $2
        "<h2 id=\"#{ $1.gsub('_', '-') }\">#{ text }</h2>"
      end
      html.gsub! /<li>/, '  \\0'
      html.gsub! " style='text-align: left;'", ''
      html.gsub! /<(\w+)( (\w+)='(.+?)')>/ do
        "<#{ $1 }#{ $2.gsub('\'', '"') }>"
      end
      html.gsub! /<img(.+?) ?\/>/, '<img\\1>'
      
      # fix image URLs
      html.gsub! 'images/images', 'images'
      
      html
    end

    def initialize_engine
      super
      return if defined? ::ERB
      require_template_library 'erb'
    end
  end
  %w(mderb rmd).each do |ext|
    register ext, MdErbTemplate
  end
end
