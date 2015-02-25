# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
	# Set tags input. model model list looks strange..
	$("#model_model_list,#snippet_model_list").tagsinput
		tagClass: (item) -> return 'label label-danger'
		typeahead:
			source: (query) ->
				$.get "../../models/autocomplete",
					tag: query
				, ((data) ->
					return data
				)

