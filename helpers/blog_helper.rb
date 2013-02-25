require 'date'
require 'fileutils'
include FileUtils

module BlogHelper

  class Post
    attr_accessor :title, :date, :permalink, :description, :thumb
  end

  def blog_posts(posts_dir = "posts", max = 9999)
    dir = File.join(Dir.getwd, 'source', posts_dir)
    posts = []
    Dir["#{dir}/*.html.*"].each do |file|
      if file =~ /\/([^\/]+?)\.html\.(haml|rmd)/
        haml = File.read(file)
        post = Post.new
        post.permalink = posts_dir + '/' + $1 + '.html'
        post.date = extract_instance_variable(haml, :date)
        post.title = extract_instance_variable(haml, :title)
        post.description = extract_instance_variable(haml, :description)
        post.thumb = extract_instance_variable(haml, :thumb)
        posts << post
      end
    end
    posts = posts.sort_by{ |item| item.date }.reverse[0..max - 1]
  end

  def previous_blog_post(posts_dir = "posts")
    posts = blog_posts(posts_dir)
    index = posts.find_index { |p| p.permalink == request.route[1..-1] }
    posts[index - 1] if index and index > 0
  end

  def next_blog_post(posts_dir = "posts")
    posts = blog_posts(posts_dir)
    permalink = request.route[1..-1]
    index = posts.find_index { |p| p.permalink == permalink }
    posts[index + 1] if index and index < posts.length - 2
  end

  def blog(posts_dir = "posts", max = 9999)
    blog_posts(posts_dir, max).each do |post|
      yield post
    end
  end

  def slideshare(id)
    href = "http://static.slidesharecdn.com/swf/ssplayer2.swf?doc=#{id}&amp;rel=0"
    params = {
      'allowFullScreen' => true,
      'allowScriptAccess' => 'always',
      'movie' => href
    }.map{ |name, value| tag(:param, :name => name, :value => value) }.join
    embed = tag(:embed, :src => href, :type => 'application/x-shockwave-flash', :width => 420, :height => 360)
    %Q(<figure class="slideshare"><div><object>#{params}#{embed}</object></div></figure>)
  end

  def figure src, alt = nil
    %Q(<figure>) +
    %Q(<img src="#{src}" alt="#{alt || src.gsub('-', ' ').gsub(/\.\w+$/, '')}">) +
    (alt ? %Q(<figcaption>#{alt}</figcaption>) : '') +
    %Q(</figure>)
  end

  def article_img src, alt = nil
    %Q(<div class="image">) +
    %Q(<img src="#{src}" alt="#{alt || src.gsub('-', ' ').gsub(/\.\w+$/, '')}">) +
    %Q(</div>)
  end

private

  def extract_instance_variable(haml, var)
    if haml =~ /@#{var} ?= ?(.+)/
      eval($1)
    end
  end

end
