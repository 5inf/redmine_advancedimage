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
        arrow((10,10),90°,20,"red",2)
        arrow((20,10),90°,20,"green",3)
        arrow((30,10),90°,20,"blue",5)
        box((50,20),(30,40),"red",2)
        circle((50,50),20,"green",5)
        text((10,55),"text","red")
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

          imgurl = url_for(:controller => 'attachments', :id => attachment, :action => 'download')
          #img = image_tag(imgurl, :style => 'max-width:'+width+';max-height:'+height+';', :alt => attachment.filename)

          #TODO: calculate width and height accordingly to keep aspect ratio and also provide a correct size for the svg image

          svgimg="<image href='"+imgurl+"' height='"+height+"' width='"+width+"'/>"
          svgimg=svgimg.html_safe
                if text.present?
                        svgdefs = "<defs><marker id='head' orient='auto' markerWidth='4' markerHeight='6' refX='0.1' refY='2'> <path d='M0,0 V4 L2,2 Z' fill='red' /> </marker>  </defs> ".html_safe
                        svgcircle = "<circle cx='50%' cy='50%' r='20%' stroke='green' stroke-width='5' fill='#00000000' />".html_safe
                        svgrectangle="<rect x='50%' y='20%' width='30%' height='40%'  style='fill:blue;stroke:pink;stroke-width:5;fill-opacity:0.1;stroke-opacity:1.0' />".html_safe
                        svgpath="<path marker-end='url(#head)' stroke-width='5' fill='none' stroke='black' d='M0,0 C45,45 45,-45 90,0' />".html_safe
                        svgline1="<line marker-end='url(#head)' x1='10%' y1='10%' x2='10%' y2='30%' style='stroke:rgb(255,0,0);stroke-width:5' />".html_safe
                        svgline2="<line marker-end='url(#head)' x1='20%' y1='10%' x2='20%' y2='30%' style='stroke:rgb(100,100,0);stroke-width:5' />".html_safe
                        svgline3="<line marker-end='url(#head)' x1='30%' y1='10%' x2='30%' y2='30%' style='stroke:rgb(0,255,0);stroke-width:5' />".html_safe
                        svgtext="<text x='10%' y='55%' fill='red'>Annotiation Text</text>".html_safe

                        #svgimage = content_tag(:svg, safe_join([svgdefs, svgcircle, svgrectangle, svgpath, svgline, svgimg]), :width => width, :height => height)
                        svgimage = content_tag(:svg, safe_join([svgdefs, svgimg, svgline1, svgline2, svgline3, svgrectangle, svgcircle, svgtext]), :width => width, :height => height)

                else

                        svgimage = content_tag(:svg, safe_join([svgimg]), :width => width, :height => height)

                end

          out = ''.html_safe
          url= url_for(:controller => 'attachments', :action => 'show', :id => attachment)
          link = link_to(svgimage, url, :class => 'thumbnail', :title => title, :name => filename)
          label = content_tag(:p, content_tag(:strong, 'Figure: '+title))

          innerdivtop = content_tag(:div, link, :id => 'innertop'+divid)
          innerdivbottom = content_tag(:div, label, :id => 'innerbottom'+divid)
          outerdiv = content_tag(:div, safe_join([innerdivtop, ' ', innerdivbottom]), :id => 'outer'+divid)

          out << outerdiv
#         out << svgimage
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

