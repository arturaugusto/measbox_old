# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  create_json_editor("#laboratory_custom_forms", window.laboratoryCustomForms)
  $(".laboratory_feature").each ->
    $(".getdata").click (e) ->
      e.preventDefault()
      $(".laboratory_feature").submit()
