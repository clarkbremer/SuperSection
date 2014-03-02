     # Register and Load Extension
     require 'sketchup.rb'
     require 'extensions.rb'

     cb_extension = SketchupExtension.new "Super Section", "CB_SuperSection/super_section.rb"
     cb_extension.version = '1.1.1'
     cb_extension.description = "Add a dedicated Scene and Layer for the selected section cut"
     cb_extension.copyright = "Copyright (c) 2014, Clark Bremer"
     cb_extension.creator = "Clark Bremer"
     Sketchup.register_extension cb_extension, true