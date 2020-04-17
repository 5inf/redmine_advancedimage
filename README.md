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
Anywhere, ideally on top, on a wiki page include the macro {{wikiapproval}} to display the approved state of the page or page revision.
