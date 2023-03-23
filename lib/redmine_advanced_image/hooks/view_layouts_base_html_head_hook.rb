module RedmineAdvancedImage
	module Hooks

  	class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
    	include ActionView::Helpers::TagHelper
	
			def view_layouts_base_html_head(context)
				out = ""
  	 		out << javascript_include_tag('install.js', :plugin => 'redmine_advancedimage')
     		out << javascript_include_tag('sortable.js', :plugin => 'redmine_advancedimage')
				out << stylesheet_link_tag('sortable-theme-bootstrap.css', :plugin => 'redmine_advancedimage')
				out 
			end
 		end
	end
end

