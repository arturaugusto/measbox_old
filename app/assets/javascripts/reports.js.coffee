# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
	$(".report_editor_feature").each ->

		movingRemoveDuplicateHeader = (tables) ->
			h = $(tables).find("th").parent()
			movingRemoveDuplicateTableElem(h)
		movingRemoveDuplicateRow = (tables, n) ->
			h = $(tables).find('tr:nth-child(' + n.toString() + ')')
			movingRemoveDuplicateTableElem(h)
		movingRemoveDuplicateTableElem = (h) ->
			# Remove duplicated in sequence
			$(h).each (i, o) ->
				if i > 0
					curr = $(h)[i]
					prev = $(h)[i-1]
					# If html nodes are equal, remove current
					if curr.isEqualNode(prev)
						$(o).remove()

		
		swig.setFilter "join_tables", (input) ->
			if input.trim().length
				tables = $.parseHTML("<span>" + input + "</span>")
				#uut_ids = _.uniq($(t).find('[wrap_class]').map(function(i,x){return($(x).attr("wrap_class"))}))
				uut_range_ids = _.uniq($(tables).find('[wrap_class]').map((i, x) ->
					$(x).attr 'wrap_class'
				))
				out_tables = $.parseHTML("<span></span>")
				if uut_range_ids.length
					for uut_range_id in uut_range_ids
						table_span = $.parseHTML("<span></span>")
						wt = $(tables).find("[wrap_class='" + uut_range_id + "']")
						movingRemoveDuplicateRow(wt, 2)
						#first_table = $(wt).first()
						#last_tr_first_table = $(first_table).find('tr:last')
						for i in [1..wt.length] by 1
							$(wt).first().find('tr:last').after($(wt[i]).find("tr"))
						$(table_span).append($(wt).first())
						movingRemoveDuplicateHeader(table_span)
						$(out_tables).append(table_span)
				return $(out_tables).get(0).outerHTML

		swig.setFilter "wrap_table", (input) ->
			if input.trim().length
				tables = $.parseHTML("<span>" + input + "</span>")
				# headers
				movingRemoveDuplicateRow(tables, 2)
				movingRemoveDuplicateHeader(tables)
				# Remove all white rows
				rows = _.reject(
					$(tables).find("tr")
				, (r) -> 
					return $(r).text().trim() is ""
				)
				table_wrap = $(tables).find("table").first()
				# wrap rows
				$(table_wrap).find("tbody").append(rows)
				$(table_wrap).get(0).outerHTML

		$(".getdata").click (e) ->
			e.preventDefault()
			$(".report_feature").submit()
		generate_report = (el) ->
			data = {}
			$.getJSON("../../report_templates/" + $("#report_report_template_id").val() + ".json").done (json) ->
				template = json.value
				# Remove characteres that crashes the template engine
				template = template.replace /{%.*?%}|{{.*?}}/g, (x) ->
					return x.replace /&nbsp;/g, " "

				template = template.replace(/&lt;br&gt;/, "<br/>")

				template_parsed = $.parseHTML("<span>" + template + "</span>")
				
				# Find wrap attributes 
				$(template_parsed).find('table[wrap_code_open][wrap_code_close]').each(->
					wrap_code_open = $(this).attr("wrap_code_open")
					wrap_code_close = $(this).attr("wrap_code_close")
					wrap_caption = $(this).attr("wrap_caption")
					wrap_class = $(this).attr("wrap_class")

					$(this).removeAttr("wrap_code_open")
					$(this).removeAttr("wrap_code_close")
					$(this).removeAttr("wrap_caption")
					#$(this).removeAttr("wrap_class")


					if wrap_caption isnt undefined
						$(this).append("<caption>" + wrap_caption + "</caption>")
					if wrap_code_open.trim() isnt ""
						$(this).wrap ->
							"<wrap>" + wrap_code_open + $(this).get(0).outerHTML + wrap_code_close + "</wrap>"
						$(this).remove()
				)

				# Write template from manipulated html
				template = $(template_parsed).get(0).outerHTML


				$.getJSON("../../services/" + $("#report_service_id_ref").val() + ".json").done (data) ->
					# Get unic uut itens from data
					merged = []
					# Merge uut ids
					merged = merged.concat.apply(merged, data.spreadsheets.map((s) ->
						s.table_json.uut_ids
					))
					# lookup on assets list the merged ids
					uniq_merged = _.uniq(merged)
					uut_assets = _.filter(data.assets, (x) ->
						uniq_merged.indexOf(x.id) > -1
					)
					ref_assets = _.filter(data.assets, (x) ->
						uniq_merged.indexOf(x.id) < 0
					)

					data.uut_assets = uut_assets
					data.ref_assets = ref_assets
					data.now = new Date()
					# Remove last row of each spreadsheet
					data.spreadsheets.map (x) ->
						x.table_json.table_data.splice -1, 1
						return



					console.log data
					html = swig.render(template,"locals": data)
					el.setHTML html
					return
				return

		# froala editor
		$("#report_value").editable 
			inlineMode: true
			buttons: [
				"save_report"
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
				"html"
				"generate"
				"pdf"
			]
			blockTags: ["p"]
			customButtons:
				save_report:
					title: "Save"
					icon:
						type: "font"
						value: "fa fa-floppy-o"
					callback: ->
						$(".getdata").trigger("click")
				pdf:
					title: "PDF"
					icon:
						type: "font"
						value: "fa fa-file-pdf-o"
					callback: ->
						filename = $("#report_name").val()
						this_url = (document.URL).replace(/\/edit$/, '')
						window.open(this_url + ".pdf", "_self")
				generate:
					title: "Generate"
					icon:
						type: "font"
						value: "fa fa-file-text-o"
					callback: ->
						console.log this
						generate_report(this)
		$('.generate').click (e) ->
			el = $('#report_value').data('fa.editable')
			generate_report(el)
			e.preventDefault()