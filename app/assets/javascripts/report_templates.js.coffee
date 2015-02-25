# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
	$(".report_template_editor_feature").each ->

		###input = '<p class=""><span>blabla</span><span style="color: rgb(51, 51, 51); font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.600000381469727px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); display: inline !important; float: none;">{% filter wrap_table %}{% for a in assets %}</span></p><p class=""><span style="color: rgb(51, 51, 51); font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.600000381469727px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); display: inline !important; float: none;">{% blablabla %}</span></p>'
		window.html = $.parseHTML(input)
		window.s = $(html).find("span")
		replaceWith = ""
		_x = $(s).each ((i,x) ->
			t = $(s[i]).contents().text()
			if i > 0
				replaceWith = replaceWith + t
			else
				replaceWith 

		)
		console.log replaceWith
		###
		# froala editor
		$("#report_template_value").editable 
			inlineMode: false
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
			]
			#blockTags: ["p"]
			#customButtons:
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
