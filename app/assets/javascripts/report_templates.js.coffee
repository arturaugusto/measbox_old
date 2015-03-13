# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
	$(".report_template_editor_feature").each ->

		header_footer = 
			type: "object"
			options:
				collapsed: true
				disable_edit_json: true
			properties:
				content:
					type: "code"
					format: "html"

		$(".pdf_options_holder").each ->
			element = this
			schema =
				title: "PDF Options"
				type: "object"
				required: false
				options:
					collapsed: true
					disable_edit_json: true
				properties:
					orientation:
						type: "string"
						enum: [
							"Portrait"
							"Landscape"
						]
					page_size:
						type: "string"
						enum: [
							"A4"
							"Letter"
						]						
					margin:
						type: "object"
						options:
							collapsed: true
							disable_edit_json: true
						properties:
							top:
								type: "number"
							bottom:
								type: "number"
							left:
								type: "number"
							right:
								type: "number"
					header: header_footer
					footer: header_footer

			editor = new JSONEditor(element,
				theme: "bootstrap3"
				iconlib: "bootstrap3"
				disable_collapse: false
				schema: schema
				)
			data_string = $('#report_template_pdf_options').val()
			if data_string isnt ""
				editor.setValue JSON.parse(data_string)
			editor.on "change", ->
				data = editor.getValue()
				data_string_2 = JSON.stringify(data)
				$('#report_template_pdf_options').val(data_string_2)
		# froala editor
		$(".code_wrap_done").click (event) ->
			event.preventDefault()
			table = $('#myModal').data("target")
			wrap_code_open = $(table_wrap_code_open).val()
			wrap_code_close = $(table_wrap_code_close).val()
			wrap_caption = $(table_wrap_caption).val()

			$(table[0]).attr("wrap_code_open", wrap_code_open)
			$(table[0]).attr("wrap_code_close", wrap_code_close)
			$(table[0]).attr("wrap_caption", wrap_caption)


		$("#report_template_value").editable 
			inlineMode: true
			paragraphy: false
			blockStyles: false
			buttons: [
				"bold"
				"italic"
				"underline"
				"strikeThrough"
				"subscript"
				"superscript"
				"fontFamily"
				"fontSize"
				"color"
				"formatBlock"
				"blockStyle"
				"align"
				"insertOrderedList"
				"insertUnorderedList"
				"outdent"
				"indent"
				"selectAll"
				"createLink"
				"insertImage"
				"insertVideo"
				"table"
				"undo"
				"redo"
				#"removeMarkers"
				"editTags"
				"html"
				"get_selection"
			]
			#blockTags: ["p"]
			customButtons:
				get_selection:
					title: "Get Selection"
					icon:
						type: "font"
						value: "fa fa-edit"
					callback: ->
						#this.removeFormat()
						#this.removeMarkers()
						table = $(this.getSelectionParent()).closest("table")
						if (table[0] isnt undefined) and (table[0].tagName is "TABLE")
							
							wrap_code_open = $(table[0]).attr("wrap_code_open")
							wrap_code_close = $(table[0]).attr("wrap_code_close")
							wrap_caption = $(table[0]).attr("wrap_caption")
							
							$(table_wrap_code_open).val(wrap_code_open)
							$(table_wrap_code_close).val(wrap_code_close)
							$(table_wrap_caption).val(wrap_caption)

							$('#myModal').data("target", table)
							$('#myModal').modal('show')
			#	removeMarkers:
			#		title: "Remove Markers"
			#		icon:
			#			type: "font"
			#			value: "fa fa-file-text-o"
			#		callback: ->
			#			$("#report_template_value").editable("removeMarkers")
			#customButtons:
			#	editTags:
			#		title: "Create/Edit tag"
			#		icon:
			#			type: "font"
			#			value: "fa fa-edit"
			#		callback: ->
			#			$('#tagEditModal').modal('show')
