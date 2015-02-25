# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
	$(".service_datatables_feature").each ->
			# Datatables
			tableContainer = $('#services')
			tableContainer.dataTable
				searchDelay: 1000			
				pagingType: 'full_numbers'
				sPaginationType: "bootstrap"
				bAutoWidth: false
				bStateSave: false
				bPaginate: true
				bProcessing: false
				bServerSide: true
				sAjaxSource: $('#services').data('source')
				fnPreDrawCallback: ->
				fnRowCallback: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
				fnDrawCallback: (oSettings) ->
			$(".input-daterange").datepicker forceParse: false
	$(".information_holder").each ->
		element = this
		$.getJSON("../../laboratories/" + $(".laboratory_id").data("lab-id") + ".json").done (json) ->
			schema = json.custom_forms
			editor = new JSONEditor(element,
				theme: "bootstrap3"
				iconlib: "bootstrap3"
				disable_collapse: false
				schema: schema
				)
			data_string = $('#service_information').val()
			if data_string isnt ""
				editor.setValue JSON.parse(data_string)
			editor.on "change", ->
				data = editor.getValue()
				data_string_2 = JSON.stringify(data)
				$('#service_information').val(data_string_2)

	$(".sortable_elements").each ->
		# Sortable
		el = document.getElementById('spreadsheets_tbody')
		sort = Sortable.create el,
			handle: '.my-handle'
			animation: 150
			onUpdate: (evt) ->
				serialized = "spreadsheets": this.toArray()
				url = $(el).data('update-url')
				#itemEl = evt.item  # dragged HTMLElement
				$.post(url, serialized)
				# + indexes from onEnd			