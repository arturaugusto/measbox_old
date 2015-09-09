# Replace comma imput do dot
jQuery -> 
  JSONEditor.defaults.editors.dotdecimal = JSONEditor.defaults.editors.number.extend
    sanitize: (value) ->
      value = (value + "").replace(',','.')
      (value + "").replace /[^0-9\.\-eE]/g, ""

  JSONEditor.defaults.editors.random_number = JSONEditor.defaults.editors.number.extend
    afterInputReady: ->
      if this.getValue().toString() is "0"
        this.setValue( Date.now() )
    unregister: ->
      this.setValue( Date.now() )
      this._super()
    # TODO: When property is after before creation, value is 0

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
          options = $.extend({},
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

        # CUSTOM BEGIN
        else if @options.froala and window.jQuery and window.jQuery.fn and window.jQuery().editable
          options = window.jQuery.extend({},
            inlineMode: false
          , self.options or {})
          window.jQuery(self.input).editable(options)
          # Set backgound option, because the JSONEditor overrides froala bg
          window.jQuery(self.input).parent().find(".froala-box").css( "background", "#FFFFFF" )
          # Get editor's value
          window.jQuery(self.input).on 'editable.contentChanged', (e, editor) ->
            val = window.jQuery(self.input).editable("getHTML", true, true)           
            # Set the value and update
            self.input.value = val
            self.value = val
            self.is_dirty = true
            if self.parent
              self.parent.onChildEditorChange self
            else
              self.jsoneditor.onChange()
            self.jsoneditor.notifyWatchers self.path
            return
        # CUSTOM END
        
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
          @ace_editor.$blockScrolling = Infinity
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
  # Add Fullscreen feature to code all editors
  dom = ace.define.modules["ace/lib/dom"]
  commands = ace.define.modules["ace/commands/default_commands"].commands
  commands.push
    name: "Toggle Fullscreen"
    bindKey: "F11"
    exec: (editor) ->
      dom.toggleCssClass document.body, "fullScreen"
      dom.toggleCssClass editor.container, "fullScreen-editor"
      editor.resize()
      return
  # Register some other editors
  JSONEditor.defaults.resolvers.unshift (schema) ->
    "dotdecimal" if schema.type is "number"

  JSONEditor.defaults.resolvers.unshift (schema) ->
    "random_number" if schema.type is "random_number"

  JSONEditor.defaults.resolvers.unshift (schema) ->
    if schema.type is 'object' and schema.format is 'hot'
      return 'hot'

  JSONEditor.defaults.resolvers.unshift (schema) ->
    "code" if schema.type is "code"


  ############################
  # Markdown editor with mathjax (has nothing to do with jdon-editor)
  ############################
  window.md_editor_create = ($el, $sync_to) ->

    convert_mathjax = () ->
      win = undefined
      executeMathJax = (win) ->
        win.MathJax.Hub.Queue new (win.Array)('Typeset', win.MathJax.Hub)
        return
      executeMathJax window
      return

    $el.text($sync_to.val())
    md_editor = $el.markdownEditor
      preview: true
      onPreview: (content, callback) ->
        callback kramed(content)
        convert_mathjax()
        return
    md_ace_editor = ace.edit($el.find('.md-editor')[0])
    md_ace_editor.$blockScrolling = Infinity
    md_ace_editor.on('change', () ->
      $sync_to.val( md_editor.markdownEditor('content') )
    )

