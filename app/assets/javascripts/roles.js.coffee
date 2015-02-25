jQuery ->
	$(".roles_feature").each ->
		element = document.getElementById('editor_holder')
		window.editor = new JSONEditor(element, 
			theme: "bootstrap3"
			iconlib: "bootstrap3"
			disable_collapse: false
			schema:
				window.rolesSchema
		)
		editor.on "ready", ->
			json_string_val = $("#role_the_role").val()
			if json_string_val isnt ""
				editor.setValue(JSON.parse($("#role_the_role").val()))
			editor.on "change", ->
				$("#role_the_role").val(JSON.stringify(editor.getValue()))