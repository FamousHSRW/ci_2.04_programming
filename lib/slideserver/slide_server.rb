require './lib/slideserver/helper/content_helper'

module SlideServer

  class Server < Sinatra::Base
    set :root, "base"
    set :views, "base"

    set :sprockets, Sprockets::Environment.new
    settings.sprockets.css_compressor = :scss
    settings.sprockets.append_path('template/assets')
    settings.sprockets.append_path('images')

    set :bind, "::"

    helpers Helper::ContentHelper

    get "/assets/*" do
      env['PATH_INFO'].sub!('/assets', '')
      settings.sprockets.call(env)
    end

    get "/stylesheet/*" do
      settings.sprockets.call(env)
    end

    get "/javascript/*" do
      settings.sprockets.call(env)
    end

    get "/graph/*.*" do |filename, ext|
      fullpath = File.join("graphs", "#{filename}.dot")

      graph = GraphViz.parse( fullpath ) {|g| }

      case ext
      when "jpg"
        content_type "image/jpeg"
        output = graph.output :jpeg => String

      when "png"
        content_type "image/png"
        output = graph.output :png => String

      else
        content_type "image/svg+xml"
        output = graph.output :svg => String
      end

      body output
    end

    get /\/(index\..*)*/i do
      haml :index,
        :layout => :layout,
        :layout_options => { views:  "template" }
    end

    get "/:type/" do |type|
      haml :index,
        :views => type,
        :layout => :layout,
        :layout_options => { views:  "template" }
    end

    get "/:type/:filename.:ext" do |type, filename, ext|
      case ext
      when 'html', 'haml', 'md'
        haml filename.to_sym,
          :views => type,
          :layout => :layout,
          :layout_options => { views: "template" }
      when 'svg', 'png', 'jpg', 'tiff', 'jpeg'
        puts Dir.pwd
        puts "Path: '#{type}', File: '#{filename}.#{ext}'"
        #content_type "image/svg+xml"
        send_file File.join(type, "#{filename}.#{ext}")
      end
    end

    get "/images/:filename" do
      settings.sprockets.call(env)
      #content_type "image/svg+xml"
    end
  end

end

