jQuery ->
	$(".values_datatables_feature").each ->
			tableContainer = $(this)
			tableContainer.dataTable
				searchDelay: 1000			
				sPaginationType: "bootstrap"
				responsive: true
				pagingType: 'full_numbers'
				bAutoWidth: false
				bStateSave: false
				bPaginate: true
				bProcessing: false
				bServerSide: true
				sAjaxSource: tableContainer.data('source')
				fnServerParams: (aoData) ->
					aoData.push 
						name: "klass"
						value: tableContainer.data('klass')
				fnPreDrawCallback: ->
				fnRowCallback: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
				fnDrawCallback: (oSettings) ->
					$(".value_chooser_feature").each ->
						$(".value_chooser_option").click (event) ->
							event.preventDefault()
							fieldset = $(this).closest("fieldset")
							fieldset.find(".value_label").text( $(this).data("name") )
							fieldset.find(".value_reference").val( $(this).data("id") )
			$(".input-daterange").datepicker forceParse: false	