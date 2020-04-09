# encoding: utf-8

require 'redmine'


Redmine::Plugin.register :redmine_advancedimage do

  name 'Redmine Advanced Image plugin'
  author '5inf'
  description 'This macro provides images subtitles and anotation capabilites.'
  version '0.0.0'
  url 'https://github.com/5inf/redmine_advancedimage'
  author_url 'https://github.com/5inf/'

  Redmine::WikiFormatting::Macros.register do
  desc <<-DESCRIPTION
  Show an image with a subtitle and optionally add annotations to the image (not implemented yet)
  Syntax:
     {{advimg(FILENAME[,width=WIDTH,height=HEIGHT,title=TITLE)}}
     FILENAME = the filename of the attached image
     WIDTH = The maximum width of the image, aspect ratio is kept
     HEIGHT = The maximum height of the image, aspect ratio is kept
     TITLE = Title to display below the image. If empty the filename is used

     {{imglink(FILENAME)}}

  Examples:
        {{advimg(test.png)}}

        {{advimg(test.png,width=200px,height=400px,title=title)

        {{advimg(test.png,width=200px,height=400px,title=title)
        arrow((50,50),90°,20,"red")
        box((20,10),(30,40),"red",2)
        text((50,90),"text","color"
        }}

        {{imglink(test.png)}}

        DESCRIPTION

macro :advimg do |obj, args, text|
        args, options = extract_macro_options(args, :width, :height, :title)
        filename = args.first
        raise 'Filename required' unless filename.present?

        if obj && obj.respond_to?(:attachments) && attachment = Attachment.latest_attach(obj.attachments, filename)
          title = options[:title] || attachment.title || filename
          divid = "advimg" + SecureRandom.urlsafe_base64(8)
          width = options[:width] || "50px"
          height = options[:height] || "50px"

          img = image_tag(url_for(:controller => 'attachments', :id => attachment, :action => 'download'), :style => 'max-width:'+width+';max-height:'+height+';', :alt => attachment.filename)

          out = ''.html_safe
          link = link_to(img, url_for(:controller => 'attachments', :action => 'show', :id => attachment), :class => 'thumbnail', :title => title, :name => filename)
          label = content_tag(:p, content_tag(:strong, 'Figure: '+title))

          out << link
          out << label
          out

        else
          raise "Attachment #{filename} not found"
        end
    end

macro :imglink do |obj, args|
        args, options = extract_macro_options(args, :width, :height, :title)
        filename = args.first
        raise 'Filename required' unless filename.present?

        out = ''.html_safe
        #out << content_tag(:a,'Figure: '+filename, :href => '#'+filename)
        out << content_tag(:a,''+filename, :href => '#'+filename)

        out

    end


  end
end
