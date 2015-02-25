# This js fix and format the datapickers
jQuery ->
	tmpDate = ""
	$(".input-group.date").datepicker
		format: "MM dd, yyyy"
		forceParse: false
	.on "show", (e) ->
		tmpDate = $(this).find("input").val()
	.on "hide", (e) ->
		$(this).find("input").val(tmpDate)