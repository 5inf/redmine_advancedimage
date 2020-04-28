Redmine AdvancedImage Macro Plugin
==================================

This plugin provides a macro to display images with subtitles and anotation capabilites and
a macro to reference an image from within a wiki page.
Also included are macros to display tables with headers and formulas with labels as well as capabilities to link to each of them.
Formula support requires the redmine_latex_mathjax (https://github.com/5inf/redmine_latex_mathjax) or a similar plugin to be installed.

Requirements
------------

Redmine 4.1.x
Other versions are not tested but may work.
Versions before 4.1 are lacking an API function that this plugin currently uses.

Installation
------------
1. Download archive and extract to /your/path/to/redmine/plugins/
2. Restart Redmine

Login to Redmine and go to Administration->Plugins. You should now see 'Redmine AdvancedImage'. Enjoy!

Usage
------------

### figure macro
 
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

### figurelink macro

Print a link to a figure crated by a {{figure}} macro. The label must match the label of the figure.
    
Syntax:

	  {{figurelink(LABEL,title=TITLE)}}
  
    Examples:
	  {{figurelink(test.png)}}
    table
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

### tablelink macro

Print a link to a table crated by the {{table}} macro. The label must match the label of the table.

Syntax:
      
      {{tablelink(LABEL,title=TITLE)	}}
      LABEL = the label referencing the table
      TITLE = an optional title
      
Examples:

    {{tablelink(tablelabel)}}
    
### formula macro

Print a (latex) fomula which can be referenced by the {{formulalink}} macro.
 
Syntax:
       
      {{formula(LABEL,title=TITLE)}}
      LABEL = the label used for referencing the formula
      TITLE = an optional title
      FORMULA = the actual code of the formula e.g. 4+5 or $4+5$. Using Laxtex fomulas requires the Redmine LaTeX MathJax Macro to be installed
    
Examples:

     {{formula(sum,title=sum over i)
     $ um_i$
     }}
    
### formulalink macro

Print a link to a formula crated by the {{formula}} macro. The label must match the label of the formula.

Syntax:

      {{formulalink(LABEL,title=TITLE)}}
      LABEL = the label referencing the table
      TITLE = an optional title
    
Examples:

      {{formulalink(formulalabel)}}
