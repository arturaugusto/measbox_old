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
		# Hide while it loads from request
		$("#service_information").hide()
		element = this
		$.getJSON("../../laboratories/" + $(".laboratory_id").data("lab-id") + ".json").done (json) ->
			try
				schema = JSON.parse(json.custom_forms.services)
				create_json_editor("#service_information", schema)
			catch e
				$("#service_information").val("{}")
			

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