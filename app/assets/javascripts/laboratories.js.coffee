# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
	$(".custom_forms_holder").each ->

		element = this
		editor = new JSONEditor(element,
			theme: "bootstrap3"
			iconlib: "bootstrap3"
			disable_collapse: false
			schema: 
				options:
					collapsed: true
				type: "object"
				title: "Calibration Information default layout"
				properties: {}
			)

		data_string = $('#laboratory_custom_forms').val()
		if data_string isnt ""
			editor.setValue JSON.parse(data_string)
		editor.on "change", ->
			data = editor.getValue()
			data_string_2 = JSON.stringify(data)
			$('#laboratory_custom_forms').val(data_string_2)