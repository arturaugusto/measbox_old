# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
breakpointDefinition =
	tablet: 1024
	phone: 480
jQuery ->
	$(".asset_datatables_feature").each ->
		tableContainer = $('#assets_datatable')
		tableContainer.dataTable
			searchDelay: 1000
			pagingType: 'full_numbers'
			#dom: "l<\"toolbar-assets\">rtip" # To understand this crap, see http://datatables.net/reference/option/dom , the "f" was removed, as i'm using a custom search field
			sPaginationType: "bootstrap"
			bAutoWidth: false
			bStateSave: false
			bPaginate: true
			bProcessing: false
			bServerSide: true
			columnDefs: [
				orderable: false
				targets: 5
			]			
			sAjaxSource: $('#assets_datatable').data('source')
			fnPreDrawCallback: ->
			fnRowCallback: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
			fnDrawCallback: (oSettings) ->
				#$(".assets_holder_feature").each ->
	$(".assets_holder_feature").each ->
		# FLag label as changeable
		$('form').on 'click', '.changeable', (event) ->
			event.preventDefault()
			that = this
			$(".changeable").each ->
				if this isnt that
					$(this).parent().attr('changing', "false")
					$(this).removeClass( "label-default" )
					$(this).addClass( "label-primary" )					
			if $(this).parent().attr('changing') is "true"
				$(this).removeClass( "label-default" )
				$(this).addClass( "label-primary" )
				$(this).parent().attr('changing', "false")
			else
				$(this).removeClass( "label-primary" )
				$(this).addClass( "label-default" )
				$(this).parent().attr('changing', "true")
		# get the template for asset fields, that is rendered on a hidden field
		asset_fields_template = $("#asset_template").data("fields")
		$('form').on 'click', '.remove_fields', (event) ->
			$(this).closest('fieldset').remove()
			event.preventDefault()
		$('form').on 'click', '.add_asset_fields', (event) ->
			event.preventDefault()
			# Get id of asset stored on href
			asset_id = $(this).attr("data-id")
			changing_items = $.find("fieldset[changing='true']")
			if changing_items.length
				changing = true
			else
				changing = false
			# If already exists or is not changing a item, dont continue
			if (not $("#service_asset_ids_" + asset_id).length)
				$.get "../../assets/get_json",
					id: asset_id
				, ((data) ->
					data.button_role = "remove"
					if changing
						data.position = $(changing_items).find(".position_map").val()
						data.changeable = "changeable"
						html = swig.render(asset_fields_template,locals: data)
						$(changing_items).replaceWith(html)
					else
						time = new Date().getTime()
						data.position = time
						html = swig.render(asset_fields_template,locals: data)
						$(".assets_holder_feature").before(html)
				)