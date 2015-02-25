# Replace comma imput do dot
jQuery ->
	JSONEditor.defaults.editors.dotdecimal = JSONEditor.defaults.editors.number.extend
		sanitize: (value) ->
			value = (value + "").replace(',','.')
			(value + "").replace /[^0-9\.\-eE]/g, ""
	JSONEditor.defaults.editors.code = JSONEditor.defaults.editors.string.extend(
		afterInputReady: ->
			self = this
			options = undefined
			
			# Code editor
			if @source_code
				
				# WYSIWYG html and bbcode editor
				if @options.wysiwyg and [
					"html"
					"bbcode"
				].indexOf(@input_type) >= 0 and window.jQuery and window.jQuery.fn and window.jQuery.fn.sceditor
					options = $extend({},
						plugins: (if self.input_type is "html" then "xhtml" else "bbcode")
						emoticonsEnabled: false
						width: "100%"
						height: 300
					, JSONEditor.plugins.sceditor, self.options.sceditor_options or {})
					window.jQuery(self.input).sceditor options
					self.sceditor_instance = window.jQuery(self.input).sceditor("instance")
					self.sceditor_instance.blur ->
						
						# Get editor's value
						val = window.jQuery("<div>" + self.sceditor_instance.val() + "</div>")
						
						# Remove sceditor spans/divs
						window.jQuery("#sceditor-start-marker,#sceditor-end-marker,.sceditor-nlf", val).remove()
						
						# Set the value and update
						self.input.value = val.html()
						self.value = self.input.value
						self.is_dirty = true
						if self.parent
							self.parent.onChildEditorChange self
						else
							self.jsoneditor.onChange()
						self.jsoneditor.notifyWatchers self.path
						return

				
				# EpicEditor for markdown (if it's loaded)
				else if @input_type is "markdown" and window.EpicEditor
					@epiceditor_container = document.createElement("div")
					@input.parentNode.insertBefore @epiceditor_container, @input
					@input.style.display = "none"
					options = $extend({}, JSONEditor.plugins.epiceditor,
						container: @epiceditor_container
						clientSideStorage: false
					)
					@epiceditor = new window.EpicEditor(options).load()
					@epiceditor.importFile null, @getValue()
					@epiceditor.on "update", ->
						val = self.epiceditor.exportFile()
						self.input.value = val
						self.value = val
						self.is_dirty = true
						if self.parent
							self.parent.onChildEditorChange self
						else
							self.jsoneditor.onChange()
						self.jsoneditor.notifyWatchers self.path
						return

				
				# ACE editor for everything else
				else if window.ace
					mode = @input_type
					
					# aliases for c/cpp
					mode = "c_cpp"  if mode is "cpp" or mode is "c++" or mode is "c"
					@ace_container = document.createElement("div")
					@ace_container.style.width = "100%"
					@ace_container.style.position = "relative"
					@ace_container.style.height = "400px"
					# CUSTOM BEGIN
					if self.options.height
						@ace_container.style.height = self.options.height
					# CUSTOM END
					@input.parentNode.insertBefore @ace_container, @input
					@input.style.display = "none"
					@ace_editor = window.ace.edit(@ace_container)
					# CUSTOM BEGIN
					@ace_editor.setValue @getValue(), -1
					# CUSTOM END
					
					# The theme
					@ace_editor.setTheme "ace/theme/" + JSONEditor.plugins.ace.theme  if JSONEditor.plugins.ace.theme
					# The mode
					mode = window.ace.require("ace/mode/" + mode)
					@ace_editor.getSession().setMode new mode.Mode()  if mode
					# Listen for changes
					@ace_editor.on "change", ->
						val = self.ace_editor.getValue()
						self.input.value = val
						self.refreshValue()
						self.ace_editor.resize()
						self.is_dirty = true
						if self.parent
							self.parent.onChildEditorChange self
						else
							self.jsoneditor.onChange()
						self.jsoneditor.notifyWatchers self.path
						return

			self.theme.afterInputReady self.input
			return
	)