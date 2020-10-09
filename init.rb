# encoding: utf-8

require 'redmine'
require File.dirname(__FILE__) + '/lib/redmine_advancedimage/hooks/view_layouts_base_html_head_hook'

Redmine::Plugin.register :redmine_advancedimage do

  name 'Redmine advanced image plugin'
  author '5inf'
  description 'This plugin provides a macro to display images with subtitles and anotation capabilites an a macro to reference an image from within a wiki page.'
  version '0.0.4'
  url 'https://github.com/5inf/redmine_advancedimage'
  author_url 'https://github.com/5inf/'

    Redmine::WikiFormatting::Macros.register do
    desc <<-DESCRIPTION
Show an figure consisting of an image with title below and optionally add annotations to the image.
The image can be referenced by the {{figurelink}} macro
Syntax:
	{{figure(FILENAME[,label=LABEL,title=TITLE,width=WIDTH,height=HEIGHT,border=BORDER)
		[ANNOTATIONS]
	}}
	FILENAME = the filename of the attached image
	LABEL = Label under which the figure is referenced. FILENAME is used if no label is given
	TITLE = Title to display below the image. If empty the LABEL or FILENAME is used
	WIDTH = The maximum width of the image, aspect ratio is kept
	HEIGHT = The maximum height of the image, aspect ratio is kept
	BORDER = An optional border around the actual image to provide extra space for annotations
	ANNOTATIONS = Annotations overlaying the picture. Supported are arrows, boxes, circles and text. See examples for details

	{{figurelink(LABEL,title=TITLE)}}

Examples:
	{{figure(test.png)}}

	{{figure(test.png,width=200px,height=400px,title=title)

	{{figure(test.png,label=test,title=A test image,width=200px,height=400px,border=20)
		arrow((10,10),90,20,"red",2)
		arrow((20,10),90,20,"green",3)
		arrow((30,10),90,20,"blue",5)
		box((50,20),(30,40),"red",2)
		circle((50,50),20,"green",5)
		text((10,55),"text","red")
	}}
DESCRIPTION

    macro :figure do |obj, args, text|
      args, options = extract_macro_options(args, :width, :height, :title, :label, :border)
      filename = args.first
      label = options[:label] || filename
			border= options[:border].to_i || 0
      raise 'Filename required' unless filename.present?
  
      regarrow = /arrow\(\s?\(\s?(-?\d+)\s?,\s?(-?\d+)\s?\)\s?,\s?(\d+)\s?,\s?(\d+)\s?,\s?"(\w+)"\s?,\s?(\d+)\s?\)/m
      regcircle = /circle\(\s?\(\s?(-?\d+)\s?,\s?(-?\d+)\s?\)\s?,\s?(\d+)\s?,\s?"(\w+)"\s?,\s?(\d+)\s?\)/m
      regtext = /text\(\s?\(\s?(-?\d+)\s?,\s?(-?\d+)\s?\)\s?,\s?"([\w\s]+)"\s?,\s?"(\w+)"\s?\)/m
      regbox = /box\(\s?\(\s?(-?\d+)\s?,\s?(-?\d+)\s?\)\s?,\s?\(\s?(\d+)\s?,\s?(\d+)\s?\)\s?,\s?"(\w+)"\s?,\s?(\d+)\s?\)/m
      #https://regex101.com/


      if obj && obj.respond_to?(:attachments) && attachment = Attachment.latest_attach(obj.attachments, filename)
        title = options[:title] || attachment.title || filename
        divid = "figure" + SecureRandom.urlsafe_base64(8)
        width = options[:width] || "50px"
        height = options[:height] || "50px"

				widthvalue = 200
				widthunit = "px"
				width.scan(/(\d+)([\w%]{1,2})/) do |match|
					widthvalue=match[0].to_i || 200
					widthunit=match[1] || "px"
				end
				heightvalue= 200
				heightunit ="px"
				svgwidthvalue=widthvalue+widthvalue*2*border/100
				height.scan(/(\d+)([\w%]{1,2})/) do |match|
					heightvalue=match[0].to_i || 200
					heightunit=match[1] || "px"
				end
				svgheightvalue=heightvalue+heightvalue*2*border/100
				xoffset=(widthvalue*border/100)
				yoffset=(heightvalue*border/100)
  
        imgurl = url_for(:controller => 'attachments', :id => attachment, :action => 'download')
        #img = image_tag(imgurl, :style => 'max-width:'+width+';max-height:'+height+';', :alt => attachment.filename)

        #TODO: calculate width and height accordingly to keep aspect ratio and also provide a correct size for the svg image
  
        out = ''.html_safe

        svginternalimage="<image href='"+imgurl+"' x='"+xoffset.to_s+widthunit+"', y='"+yoffset.to_s+heightunit+"', height='"+heightvalue.to_s+heightunit+"' width='"+widthvalue.to_s+widthunit+"'/>"
        svginternalimage=svginternalimage.html_safe
      
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
              x2=(widthvalue*(match[0].to_i+border)/100).to_s
              y2=(heightvalue*(match[1].to_i+border)/100).to_s
              angle=match[2].to_s
              length=match[3].to_s
              color=match[4].to_s
              strokeWidth=match[5].to_s
              x1=(x2.to_i-length.to_i*heightvalue/100*Math::sin(angle.to_i*Math::PI/180)).to_s
              y1=(y2.to_i-length.to_i*widthvalue/100*Math::cos(angle.to_i*Math::PI/180)).to_s
              headid="headid" + SecureRandom.urlsafe_base64(8)
              svgdef = "<defs><marker id='"+headid+"' orient='auto' markerWidth='4' markerHeight='6' refX='0.1' refY='2'> <path d='M0,0 V4 L2,2 Z' fill='"+color+"'/> </marker>  </defs> "
              svgdefs.push(svgdef.html_safe)
              svgline= "<line marker-end='url(#"+headid+")' x1='"+x1+widthunit+"' y1='"+y1+heightunit+"' x2='"+x2+widthunit+"' y2='"+y2+heightunit+"' style='stroke:"+color+";stroke-width:"+strokeWidth+";fill-opacity:0.1;stroke-opacity:1.0' />"
              svglines.push(svgline.html_safe)
            end

            line.scan(regtext) do |match|
              #out << "text"+match.to_s
              x1= (widthvalue*(match[0].to_i+border)/100).to_s
              y1= (heightvalue*(match[1].to_i+border)/100).to_s
              innertext=match[2].to_s
              color=match[3].to_s
              svgtext="<text x='"+x1+widthunit+"' y='"+y1+heightunit+"' fill='"+color+"'>"+innertext+"</text>"
              svgtexts.push(svgtext.html_safe)
            end

            line.scan(regbox) do |match|
              #out << "box"+match.to_s
              x1= (widthvalue*(match[0].to_i+border)/100).to_s
              y1= (heightvalue*(match[1].to_i+border)/100).to_s
              x2= (widthvalue*(match[2].to_i+border)/100).to_s
              y2= (heightvalue*(match[3].to_i+border)/100).to_s
              rectwidth=(x1.to_i-x2.to_i).abs.to_s
              rectheight=(y1.to_i-y2.to_i).abs.to_s
              color=match[4].to_s
              strokeWidth=match[5].to_s
              svgrectangle="<rect x='"+x1+widthunit+"' y='"+y1+heightunit+"' width='"+rectwidth+widthunit+"' height='"+rectheight+heightunit+"' stroke='"+color+"' stroke-width='"+strokeWidth+"' fill='#00000000' />"
              svgrectangles.push(svgrectangle.html_safe)
            end 

            line.scan(regcircle) do |match|
              #out << "circle"+match.to_s
              x1= (widthvalue*(match[0].to_i+border)/100).to_s
              y1= (heightvalue*(match[1].to_i+border)/100).to_s
              radius=match[2].to_s
              color=match[3].to_s
              strokeWidth=match[4].to_s
              svgcircle = "<circle cx='"+x1+widthunit+"' cy='"+y1+heightunit+"' r='"+radius+"%' stroke='"+color+"' stroke-width='"+strokeWidth+"' fill='#00000000' />"
              svgcircles.push(svgcircle.html_safe)
            end
          end

          svgimage = content_tag(:svg, safe_join([svgdefs, svginternalimage, svglines, svgrectangles, svgcircles, svgtexts]), :width => svgwidthvalue.to_s+widthunit, :height => svgheightvalue.to_s+heightunit)
        else
          svgimage = content_tag(:svg, safe_join([svginternalimage]), :width => svgwidthvalue.to_s+widthunit, :height => svgheightvalue.to_s+heightunit)
        end
    
        url= url_for(:controller => 'attachments', :action => 'show', :id => attachment)
        link = link_to(svgimage, url, :class => 'thumbnail', :title => title, :name => filename, :target => '_blank')
        labeltag = content_tag(:p, content_tag(:strong, 'Abbildung: '+title), :title => "label: "+label)
        innerdivtop = content_tag(:div, link, :id => 'figure.'+label)
        innerdivbottom = content_tag(:div, labeltag, :id => 'innerbottom.'+divid)
        outerdiv = content_tag(:div, safe_join([innerdivtop, ' ', innerdivbottom]), :id => 'outer'+divid)
        out << outerdiv

        out

      else
        raise "Attachment #{filename} not found"
      end
    end


    desc <<-DESCRIPTION
Print a link to a figure crated by a {{figure}} macro. The label must match the label of the figure.
Syntax:
	{{figurelink(LABEL,title=TITLE)}}
  
Examples:
	{{figurelink(test.png)}}
DESCRIPTION
    macro :figurelink do |obj, args|
      args, options = extract_macro_options(args, :title)
      label = args.first
      title = options[:title] || args.first
      raise 'label argument required' unless label.present?

      out = ''.html_safe
      #out << content_tag(:a,'Figure '+filename, :href => '#'+filename)
      out << content_tag(:a, 'Abbildung '+title, :href => '#figure.'+label, :title => label)
      out
    end

    desc <<-DESCRIPTION
Print a table with a table header which can be linked to by the {{tablelink}} macro.
Syntax:
	{{tablelink(LABEL,title=TITLE)
		TABLEDEFINITION	
	}}
	LABEL = the label referencing the table
	TITLE = an optional title
	TABLEDEFINITION = the actual code of the table in Wiki syntax  e.g. |col1|col2|.
Examples:
	{{table(tablelabel,title=The table of two entries)
		|_. Nr. |_. Entry |
		| 1 | Entry 1|
		| 2 | Entry 2|
	}}
DESCRIPTION
    macro :table do |obj, args, text|
      args, options = extract_macro_options(args, :title)
      label = args.first
      title = options[:title] || label
      raise 'label argument required' unless label.present?
      

      out = ""
      table = ""
      if text.present?
	table= RedCloth3.new(text)
        table=table.to_html
#        table = render(:partial => 'common/markup', :locals => {:markup_text_formatting => 'textile', :markup_text => text })
#       table = render(:partial => 'common/markup', :locals => {:markup_text_formatting => 'textile', :markup_text => text })
      else
        raise "no table code provided"
      end

        table = table.html_safe

        labeldiv = content_tag(:p, content_tag(:strong, 'Table: '+title), :title => "label: "+label)
        innerdivtop = content_tag(:div, labeldiv)
        innerdivbottom = content_tag(:div, table)
        outerdiv = content_tag(:div, safe_join([innerdivtop, ' ', innerdivbottom]), :id => 'table.'+label)
        out = outerdiv


      out
    end

    desc <<-DESCRIPTION
Print a link to a table crated by the {{table}} macro. The label must match the label of the table.
Syntax:
	{{tablelink(LABEL,title=TITLE)	}}
	LABEL = the label referencing the table
	TITLE = an optional title
Examples:
	{{tablelink(tablelabel)}}
DESCRIPTION
    macro :tablelink do |obj, args|
      args, options = extract_macro_options(args, :title)
      label = args.first 
			title = options[:title] || label
      raise 'label argument required' unless label.present?


      out = ''.html_safe
      out << content_tag(:a,'Tabelle '+title, :href => '#table.'+label, :title => label)
      out
    end

    desc <<-DESCRIPTION
Print a (latex) fomula which can be referenced by the {{formulalink}} macro.
Syntax:
	{{formula(LABEL,title=TITLE)}}
	LABEL = the label used for referencing the formula
	TITLE = an optional title
	FORMULA = the actual code of the formula e.g. 4+5 or $4+5$. Using Laxtex fomulas requires the Redmine LaTeX MathJax Macro to be installed
Examples:
	{{formula(sum,title=sum over i)
		$\sum_i$
	}}
DESCRIPTION
		macro :formula do |obj, args, text|
      args, options = extract_macro_options(args, :title)
      label = args.first 
      title = options[:title] || label
      raise 'label argument required' unless label.present?
      

      out = ""
      table = ""
      if text.present?
	table= RedCloth3.new(text)
        table=table.to_html
	#this reqires redmine 4.1
#       table = render(:partial => 'common/markup', :locals => {:markup_text_formatting => 'textile', :markup_text => text })
#       table = render(:partial => 'common/markup', :locals => {:markup_text_formatting => 'markdown', :markup_text => text })
      else
        raise "no formula code provided"
      end

        table = table.html_safe

        labeldiv = content_tag(:p, content_tag(:strong, 'Formel: '+title), :title => "label: "+label)
        innerdivtop = content_tag(:div, labeldiv)
        innerdivbottom = content_tag(:div, table)
        outerdiv = content_tag(:div, safe_join([innerdivtop, ' ', innerdivbottom]), :id => 'formula.'+label)
        out = outerdiv

      out
    end

    desc <<-DESCRIPTION
Print a link to a formula crated by the {{formula}} macro. The label must match the label of the formula.
Syntax:
  {{formulalink(LABEL,title=TITLE)}}
	LABEL = the label referencing the table
	TITLE = an optional title
Examples:
	{{formulalink(formulalabel)}}
DESCRIPTION
    macro :formulalink do |obj, args|
      args, options = extract_macro_options(args, :title)
      label = args.first
			title = options[:title] || label
      raise 'label argument required' unless label.present?


      out = ''.html_safe
      out << content_tag(:a,'Formel '+label, :href => '#formula.'+label, :title => label)
      out
    end

  end
end

