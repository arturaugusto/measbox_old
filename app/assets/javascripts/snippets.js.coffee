# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
	$(".snippet_datatables_feature").each ->
		# Flavors to be fetched by default
		flavor = ["1", "2"]
		$.data($("#snippets")[0], "flavor", flavor )
		# Get only math model if its on spreadsheet edit
		$(".table-json").each ->
			flavor = ["2"]
			$.data($("#snippets")[0], "flavor", flavor )
		# Get only asset model if its on spreadsheet edit
		$(".assets-holder").each ->
			flavor = ["1"]
			$.data($("#snippets")[0], "flavor", flavor )

		breakpointDefinition =
			tablet: 1024
			phone: 480

		tableContainer = $('#snippets')
		window.snippetDataTable = tableContainer.dataTable
			responsive: true
			fnSetFilteringDelay: 2000
			pagingType: 'full_numbers'
			dom: "l<\"toolbar-snippets\">rtip" # To understand this crap, see http://datatables.net/reference/option/dom , the "f" was removed, as i'm using a custom search field
			sPaginationType: "bootstrap"
			bAutoWidth: false
			bStateSave: false
			bPaginate: true
			bProcessing: false
			bServerSide: true
			columnDefs: [
				orderable: false
				targets: 2
			]
			sAjaxSource: $('#snippets').data('source')
			fnServerParams: (aoData) ->
				aoData.push
					name: "flavor"
					value: $.data($("#snippets")[0], "flavor" )
				# Mathematical Snippet como filtro dos snippets dos assets
				if $(".table-json").data( "temp-data")
					func_tag_list = $(".table-json").data( "temp-data").func_tag_list
					console.log "---"
					console.log func_tag_list
					if func_tag_list isnt undefined
						aoData.push
							name: "func_tag_list"
							value: func_tag_list

				# Add pre tags, if some
				$("#pre_tags").each ->
					if $(this).val() isnt ""
						aoData.push 
							name: "pre_tags"
							value: $(this).val()
				# Show all users snippets if chebkbox is checked
				if $("#global_snippets").prop( "checked" ) is true
						aoData.push 
							name: "global_snippets"
							value: true

			fnPreDrawCallback: ->
			fnRowCallback: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
			fnDrawCallback: (oSettings) ->
				$(".snippet_chooser_feature").each ->
					# Based on where the table is rendered, apply some modifications.
					# It gets the modifier locals deffined on the _snippets_datatable partial to apply the features
					$(".math_snippet_chooser").click (event) ->
						event.preventDefault()
						s_id = $(this).attr("s_id")
						$.get "../../snippets/get_json?id=" + s_id, (data) ->
							# The talbe is beeing created, so table_data is empty
							data.snippet.table_data = []
							# this functions is defined at spreadsheets.js.coffee
							buildHandsontable(data.snippet, data.tag_list)
							$('#myModal').modal('hide')
						return # onclick

					$(".asset_snippet_chooser").click (event) ->
						s_id = $(this).attr("s_id")
						# Get selected instruments identifiaction
						identification = $("span.search_fields[active='true']").prev().text()
						asset_id = $("span.search_fields[active='true']").parent().find(".asset_json_data").attr("asset_id")
						position = $("span.search_fields[active='true']").parent().find(".position_map").val()
						$.get "../../snippets/get_json?id=" + s_id, (data) ->
							data.snippet.asset_id = asset_id
							data.snippet.position = position
							data.snippet.snippet_id = data.snippet.id
							delete data.snippet.id

							# build text for choosen snippet
							data.snippet.label = identification + " - " + data.tag_list

							delete data.tag_list
							# Filter some stuff
							delete data.snippet.validated
							delete data.snippet.created_at
							delete data.snippet.flavor
							delete data.snippet.laboratory_id
							delete data.snippet.updated_at

							snippetsDataArray = window.chosenAssetsEditor.getEditor('root.snippets')
							snippetsDataArray.addRow(data.snippet)

							# can be this too...
							#snippetsDataArrayEditor = window.chosenAssetsEditor.getEditor('root.snippets')
							#snippetsArray = snippetsDataArrayEditor.getValue()
							#snippetsArray.push(data.snippet)
							#snippetsDataArrayEditor.setValue(snippetsArray)
						event.preventDefault()
						return # onclick

		# Listem to togglable snippets scope changer, to update datatables when toggle ocour
		$('#global_snippets').change ->
			snippetDataTable.fnDraw()

		$(".table-json").each ->
			$(".input-daterange").datepicker forceParse: false
			# Open modal
			table_json = $(".table-json").val()
			if (table_json is "") or (table_json is "{}")
				$('#myModal').modal('show')
			else
				buildHandsontable( JSON.parse(table_json) )
		# Create tags field on datatables dom
		$("div.toolbar-snippets").html('<div id="snippets_filter" class="dataTables_filter"><label>Tag search:<input type="search" class="form-control input-sm" data-role="tagsinput" id="snippets_tags_filter" aria-controls="snippets"></label></div>');

		# Start tags with typeahead
		# This is the default searchbox found on snippets index page 
		$("#snippets_tags_filter").tagsinput 
			tagClass: (item) -> return 'label label-default'
			typeahead:
				source: (query) ->
					$.get "../../snippets/autocomplete",
						tag: query
						flavor: $.data($("#snippets")[0], "flavor") # Search either math model or asset snippets
						global_snippets: $("#global_snippets").prop( "checked" ) # undefined if dont exist onpage
					, ((data) ->
						return data
					)
		# Listen changes on tags field and perform the search on datatables
		$("#snippets_tags_filter,#snippet_model_list").on "change", ->
			searchString = $("#snippets_tags_filter").val()
			on_spreadsheet = $(".spreadsheet_feature").length
			search_flavor = $.data($("#snippets")[0], "flavor" )[0]
			# To avoid double request due table change when tag is dinamicaly added
			if not ( (searchString.length is 0) and (search_flavor is "1") and (on_spreadsheet) )
				tableContainer.fnFilter( searchString )
		# The folowing action only takes place
		# inside spreadsheet, when filtering snippets for
		# a specific asset and the pre_tags exists
		$("#pre_tags").each ->
			$("#snippets_tags_filter").on "itemRemoved", (event) ->
				tags = $("#pre_tags").val().split(/[\s,]+/)
				# If trying to remove pre tag, add it again
				if indexOf.call(tags, event.item) isnt -1
					$(this).tagsinput('add', event.item)

	$(".snippet_feature").each ->
		# Hide if flavor === 2
		if $("#snippet_flavor").val() is "2"
			$(".snippet_model_list").hide()
		# Set tags input
		$("#snippet_functionality_list").tagsinput
			tagClass: (item) -> return 'label label-info'
			typeahead:
				source: (query) ->
					$.get "../../snippets/autocomplete",
						tag: query
						skip_model: true
						flavor: ["1"] # asset snippets
					, ((data) ->
						return data
					)
		# Register some other editors
		JSONEditor.defaults.resolvers.unshift (schema) ->
			"dotdecimal" if schema.type is "number"
		JSONEditor.defaults.resolvers.unshift (schema) ->
			"code" if schema.type is "code"

		setEditorListeners = ->
			# Listen for changes
			editor.on "change", ->
				data = editor.getValue()
				$('#snippet_value').val(JSON.stringify(data))
				# Enable user to submit
				$("input[type='submit']").prop('disabled', false)
		formBuilders =
			setMathForm: (element) ->
				editor = undefined
				editor = new JSONEditor(element,
					theme: "bootstrap3"
					iconlib: "bootstrap3"
					disable_collapse: false
					schema:
						type: "object"
						title: "Spreadsheet"
						properties:
							variables:
								type: "array"
								title: "Variables"
								format: "table"
								uniqueItems: true
								items:
									type: "object"
									title: "Variable"
									properties:
										kind:
											title: "Kind"
											type: "array"
											format: "checkbox"
											uniqueItems: true
											items:
												type: "string"
												enum: [
													"UUT"
													"Invisible"
												]

										name:
											title: "Name"
											type: "string"

										color:
											type: "string"
											format: "color"
											title: "Column color"
											default: "#ffffff"

								default: [
									{
										kind: ["UUT"]
										name: "uut_meas"
										color: "#F4FFA9"
									}
									{
										kind: []
										name: "ref_meas"
										color: "#C4D1FF"
									}
								]

							influence_quantities:
								type: "array"
								format: "table"
								title: "Influence Quantities"
								uniqueItems: true
								items:
									type: "object"
									title: "Influence Quantity"
									properties:
										name:
											title: "Name"
											type: "string"
										color:
											type: "string"
											format: "color"
											title: "Column color"
											default: "#ffffff"

							replications:
								type: "integer"
								title: "Replications"
								minimum: 1
								default: "4"

							formula:
								type: "code"
								title: "Mathematical Model"
								format: "r"
								default: "e <- uut_meas - ref_meas"
								options:
									height: "40px"

							automation:
								type: "code"
								title: "Automation Script"
								format: "python"
								options:
									height: "100px"
							script:
								type: "code"
								title: "Evaluation Script"
								format: "r"
								default: "library('devtools')\nsrc <- source_url('https://raw.githubusercontent.com/arturaugusto/Uncertainty-Calculator/master/unc_cal.r')\nmain <- src$value"
								options:
									height: "100px"
							output_columns:
								type: "array"
								format: "table"
								title: "Output Columns"
								uniqueItems: true
								items:
									type: "object"
									title: "Output Column"
									properties:
										name:
											title: "Name"
											type: "string"
										color:
											type: "string"
											format: "color"
											title: "Column color"
											default: "#ffffff"
								default: 
									[
										{
											name: "UUT"
											color: "#ffffff"
										}
										{
											name: "Reference"
											color: "#ffffff"
										}
										{
											name: "e"
											color: "#ffffff"
										}
										{
											name: "MPE"
											color: "#ffffff"
										}
										{
											name: "U"
											color: "#ffffff"
										}
										{
											name: "k"
											color: "#ffffff"
										}
										{
											name: "veff"
											color: "#ffffff"
										}
									]
							format_operations:
								type: "array"
								format: "table"
								title: "Format Operations"
								uniqueItems: false
								items:
									type: "object"
									title: "Format Operation"
									properties:
										output_column:
											type: "string"
											format: "string"
											title: "Out col"
											watch:
												out_cols: "root.output_columns"
											enumSource: "out_cols"
											enumValue: "{{item.name}}"
										operation:
											title: "Operation"
											type: "string"
											enum: [
												"toExponential"
												"toFixed"
												"toPrecision"
												"valueOf"
												"abs"
												"cmp"
												"eq"
												"gt"
												"gte"
												"lt"
												"lte"
												"minus"
												"mod"
												"plus"
												"pow"
												"round"
												"sqrt"
												"times"
												"toString"
											]
										argument:
											title: "Argument"
											type: "string"
								default:
									[
										{
											"output_column": "U"
											"operation": "toPrecision"
											"argument": "2"
										}
										{
											"output_column": "Reference"
											"operation": "toFixed"
											"argument": "U.resolution"
										}
										{
											"output_column": "UUT"
											"operation": "toFixed"
											"argument": "uut_meas 1.resolution"
										}
										{
											"output_column": "e"
											"operation": "toFixed"
											"argument": "uut_meas 1.resolution"
										}
										{
											"output_column": "MPE"
											"operation": "toFixed"
											"argument": "uut_meas 1.resolution"
										}
										{
											"output_column": "k"
											"operation": "toFixed"
											"argument": "2"
										}
									]
				)
				editor			
			setAssetForm: (element) ->
				editor = new JSONEditor(element, {
					theme: 'bootstrap3',
					iconlib: 'bootstrap3'
					disable_collapse: false
					schema:{
						"type": "object",
						"title": "Asset snippet",
						"properties": {
							"ranges": window.rangesSchema.ranges
						}
					}
				})
				editor
		# Submit starts disable to avoid json error on server
		$("input[type='submit']").prop('disabled', true)
		# Map flavors
		flavors = 
			1: "setAssetForm"
			2: "setMathForm"
		# Model list tags doesnt apply when its Math Model modeling
		toggleModelList = ->
			if $("#snippet_flavor").val() is "2"
				$(".snippet_model_list").hide()
				# remove all model tags
				# Algum efeito colateral comentar linha abaixo ???
				#$('#snippet_model_list').tagsinput('removeAll')
			else
				$(".snippet_model_list").show()

		# Get element holder
		element = document.getElementById('editor_holder')
		editorIndex = $("#snippet_flavor").val()
		if editorIndex isnt ""
			editor = formBuilders[ flavors[editorIndex] ](element)
			editor.setValue value
			setEditorListeners()
		$("#snippet_flavor").data("prev", $("#snippet_flavor").prop("selectedIndex") )
		$("#snippet_flavor").on "change", (e) ->
			if ( $("#snippet_flavor").data("prev") > 0 ) or ( $(".edit_snippet_feature").length )
				if not confirm("Are you sure?")
					# back to last option
					$("#snippet_flavor").prop("selectedIndex", $("#snippet_flavor").data("prev") )
					return
			optionSelected = $("option:selected", this)
			valueSelected = @value
			toggleModelList()
			# Remove existing editors
			try
				editor.destroy()
			editor = formBuilders[ flavors[valueSelected] ](element)
			# Listen for changes
			$("#snippet_flavor").data("prev", $("#snippet_flavor").prop("selectedIndex") )
			setEditorListeners()
			$("#snippet_flavor").prop("selectedIndex", $("#snippet_flavor").data("prev") )
			# Resize formula snippet
			return
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
