# encoding: utf-8

require 'redmine'


Redmine::Plugin.register :redmine_advancedimage do

  name 'Redmine advanced image plugin'
  author '5inf'
  description 'This plugin provides a macro to display images with subtitles and anotation capabilites an a macro to reference an image from within a wiki page.'
  version '0.0.2'
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
			args, options = extract_macro_options(args, :width, :height, :title, :label)
	    filename = args.first
			label = options[:label] || filename
	    raise 'Filename required' unless filename.present?
	
			regarrow = /arrow\(\s?\(\s?(\d+)\s?,\s?(\d+)\s?\)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?"(\w+)"\s?,\s?(\d+)\s?\)/m
			regcircle = /circle\(\s?\(\s?(\d+)\s?,\s?(\d+)\s?\)\s?,\s?(\d+)\s?,\s?"(\w+)"\s?,\s?(\d+)\s?\)/m
			regtext = /text\(\s?\(\s?(\d+)\s?,\s?(\d+)\s?\)\s?,\s?"([\w\s]+)"\s?,\s?"(\w+)"\s?\)/m
			regbox = /box\(\s?\(\s?(\d+)\s?,\s?(\d+)\s?\)\s?,\s?\(\s?(\d+)\s?,\s?(\d+)\s?\)\s?,\s?"(\w+)"\s?,\s?(\d+)\s?\)/m
			#https://regex101.com/


	    if obj && obj.respond_to?(:attachments) && attachment = Attachment.latest_attach(obj.attachments, filename)
 		  	title = options[:title] || attachment.title || filename
	      divid = "advimg" + SecureRandom.urlsafe_base64(8)
	      width = options[:width] || "50px"
	      height = options[:height] || "50px"
	
	      imgurl = url_for(:controller => 'attachments', :id => attachment, :action => 'download')
	      #img = image_tag(imgurl, :style => 'max-width:'+width+';max-height:'+height+';', :alt => attachment.filename)

	      #TODO: calculate width and height accordingly to keep aspect ratio and also provide a correct size for the svg image
	
				out = ''.html_safe

	      svgimg="<image href='"+imgurl+"' height='"+height+"' width='"+width+"'/>"
	      svgimg=svgimg.html_safe
      
				if text.present?
					#out << content_tag(:p, text)
	        svgdefs=Array.new
	        svglines=Array.new
	        svgtexts=Array.new
	        svgcircles=Array.new
		      svgrectangles=Array.new
	
	        lines=text.split(/\n/)
	
 	       	lines.each do |line|
 	       		line.scan(regarrow) do |match|
 	       	  	#out << "arrow"+match.to_s
 	      	    x2= match[0].to_s
 	      	    y2= match[1].to_s
 	    	      angle=match[2].to_s
 	           	length=match[3].to_s
 	           	color=match[4].to_s
 	           	strokeWidth=match[5].to_s
 	           	x1=(x2.to_i-length.to_i*Math::sin(angle.to_i*Math::PI/180)).to_s
 	           	y1=(y2.to_i-length.to_i*Math::cos(angle.to_i*Math::PI/180)).to_s
 	           	headid="headid" + SecureRandom.urlsafe_base64(8)
 	           	svgdef = "<defs><marker id='"+headid+"' orient='auto' markerWidth='4' markerHeight='6' refX='0.1' refY='2'> <path d='M0,0 V4 L2,2 Z' fill='"+color+"'/> </marker>  </defs> "
 	           	svgdefs.push(svgdef.html_safe)
 	           	svgline= "<line marker-end='url(#"+headid+")' x1='"+x1+"%' y1='"+y1+"%' x2='"+x2+"%' y2='"+y2+"%' style='stroke:"+color+";stroke-width:"+strokeWidth+";fill-opacity:0.1;stroke-opacity:1.0' />"
 	           	svglines.push(svgline.html_safe)
 	         	end

          	line.scan(regtext) do |match|
            	#out << "text"+match.to_s
            	x1= match[0].to_s
           		y1= match[1].to_s
           	 	innertext=match[2].to_s
           	 	color=match[3].to_s
           	 	svgtext="<text x='"+x1+"%' y='"+y1+"%' fill='"+color+"'>"+innertext+"</text>"
           	 	svgtexts.push(svgtext.html_safe)
          	end

          	line.scan(regbox) do |match|
            	#out << "box"+match.to_s
           		x1= match[0].to_s
            	y1= match[1].to_s
           		x2= match[2].to_s
            	y2= match[3].to_s
            	rectwidth=(x1.to_i-x2.to_i).abs.to_s
            	rectheight=(y1.to_i-y2.to_i).abs.to_s
            	color=match[4].to_s
            	strokeWidth=match[5].to_s
            	svgrectangle="<rect x='"+x1+"%' y='"+y1+"%' width='"+rectwidth+"%' height='"+rectheight+"%' style='fill:blue;stroke:pink;stroke-width:5;fill-opacity:0.1;stroke-opacity:1.0' />"
            	svgrectangles.push(svgrectangle.html_safe)
         	 	end	

          	line.scan(regcircle) do |match|
           		#out << "circle"+match.to_s
            	x1= match[0].to_s
            	y1= match[1].to_s
            	radius=match[2].to_s
            	color=match[3].to_s
            	strokeWidth=match[4].to_s
            	svgcircle = "<circle cx='"+x1+"%' cy='"+y1+"%' r='"+radius+"%' stroke='"+color+"' stroke-width='"+strokeWidth+"' fill='#00000000' />"
            	svgcircles.push(svgcircle.html_safe)
          	end
        	end

       		svgimage = content_tag(:svg, safe_join([svgdefs, svgimg, svglines, svgrectangles, svgcircles, svgtexts]), :width => width, :height => height)
      	else
        	svgimage = content_tag(:svg, safe_join([svgimg]), :width => width, :height => height)
      	end
    
  			url= url_for(:controller => 'attachments', :action => 'show', :id => attachment)
     		link = link_to(svgimage, url, :class => 'thumbnail', :title => title, :name => filename, :target => '_blank')
      	labeltag = content_tag(:p, content_tag(:strong, 'Figure ('+filename+'): '+title))
      	innerdivtop = content_tag(:div, link, :id => 'innertop'+divid)
      	innerdivbottom = content_tag(:div, labeltag, :id => 'figure.'+label)
      	outerdiv = content_tag(:div, safe_join([innerdivtop, ' ', innerdivbottom]), :id => 'outer'+divid)
      	out << outerdiv

      	out

    	else
      	raise "Attachment #{filename} not found"
    	end
  	end

		macro :imglink do |obj, args|
    	args, options = extract_macro_options(args, :label)
    	filename = args.first || options[:label]
			raise 'Filename or lable required' unless filename.present?

	    out = ''.html_safe
	    #out << content_tag(:a,'Figure '+filename, :href => '#'+filename)
	    out << content_tag(:a, 'Abbildung '+filename, :href => '#figure.'+filename)
	    out
	  end

	  macro :tableheader do |obj, args, text|
			args, options = extract_macro_options(args, :label, :title)
    	raise 'label argument required' unless options[:label].present?
			label = options[:label] 
			title = options[:title] || label
			

			out = ""
			table = ""
			if text.present?
				table = render(:partial => 'common/markup', :locals => {:markup_text_formatting => 'textile', :markup_text => text })
#				table = render(:partial => 'common/markup', :locals => {:markup_text_formatting => 'textile', :markup_text => text })
			else
				raise "no table code provided"
			end

				table = table.html_safe

				labeldiv = content_tag(:p, content_tag(:strong, 'Table ('+label+'): '+title))
        innerdivtop = content_tag(:div, labeldiv)
        innerdivbottom = content_tag(:div, table)
        outerdiv = content_tag(:div, safe_join([innerdivtop, ' ', innerdivbottom]), :id => 'table.'+label)
        out = outerdiv


			out
		end

		macro :tablelink do |obj, args|
    	args, options = extract_macro_options(args, :label)
    	raise 'label argument required' unless options[:label].present?
			label = options[:label] 

	    out = ''.html_safe
	    out << content_tag(:a,'Tabelle '+label, :href => '#table.'+label)
	    out
	  end

	end
end

