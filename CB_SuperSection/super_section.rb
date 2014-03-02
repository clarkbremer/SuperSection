##
##  Super Section
##
##  1) Add a section cut to your model.
##  2) Right click, and choose Super Section
##  3) You will be prompted for a name
##  4) A new layer and scene tab will be created for that section.
##   
##    Copyright (c) 2014, Clark Bremer
##    Version 1.1.1
##    2/10/2014, clarkbremer@gmail.com   Tested on SU 13 - 14, PC only
##
##  load "C:/Users/Clark/Documents/TimberFraming/Sketchup/Rubies/CB_SuperSection/CB_SuperSection/super_section.rb"

require 'sketchup.rb'
module CB_SS

def CB_SS.section_selected
    mm = Sketchup.active_model
    ss = mm.selection
	return nil if ss.count != 1
	return true if ss[0].instance_of? Sketchup::SectionPlane
	return nil
end


def CB_SS.get_name
    prompts = ["Name:"]
    defaults = []
    input = UI.inputbox prompts, defaults, "Enter Name of Super Section"
	if input
		return input[0].strip 
	else
		return nil
	end	
end

def CB_SS.plane_horizontal?(plane)
  snormal = Geom::Vector3d.new(plane[0], plane[1], plane[2])
  snormal.parallel? Z_AXIS
end

def CB_SS.super_section
  ss_name = get_name
  return unless ss_name
	if ss_name == ""
		UI.messagebox ss_name + " invalid name"
		return
	end
  mm = Sketchup.active_model
	section = mm.selection[0]
	mm.start_operation("Super Section", true) 
  layers = mm.layers
	pages = mm.pages
	if layers[ss_name]
		UI.messagebox ss_name + " duplicates an existing layer name"
		return
	end
	if pages[ss_name]
		UI.messagebox ss_name + " duplicates an existing scene name"
		return
	end
	
	layer = layers.add ss_name
	layer.page_behavior = LAYER_IS_HIDDEN_ON_NEW_PAGES
  pages.each { |p| p.set_visibility( layer, false ) }

	page = pages.add ss_name
	page.set_visibility layer,true
	
	section.layer = layer
	mm.active_layer = layer
	pages.selected_page = page

	view = mm.active_view
  camera = view.camera
	camera.perspective = false
	
	up = camera.up
	eye = camera.eye  # Whatever.  We'll overwrite this when we zoom extents.
  splane = section.get_plane

	eye_on_splane = eye.project_to_plane splane
	target = camera.target
	target.set!(eye_on_splane) 
  if CB_SS.plane_horizontal?(splane)
  	up.set!(1, 0, 0)  # down
	else
  	up.set!(0, 0, 1)  # level
	end
  camera.set(eye, target, up)
	view.camera = camera
	view.zoom_extents
	mm.rendering_options['DisplaySectionPlanes'] = false

	page.update
	pages.selected_page = page
  mm.commit_operation   
	mm.rendering_options['DisplaySectionPlanes'] = false
end  ## CB_SS.super_section

### menu
this_file="cb_super_section"
if not file_loaded?(this_file)
	UI.add_context_menu_handler do |menu|
		if menu == nil then 
			UI.messagebox("Error setting context menu handler")
			return
		end
		if CB_SS.section_selected
			menu.add_item("Super Section") {CB_SS.super_section}
		end
	end	
  file_loaded(this_file)
end

end # module CB_SS