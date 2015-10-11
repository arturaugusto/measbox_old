# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  create_json_editor("#laboratory_custom_forms", window.laboratoryCustomForms)
  $(".laboratory_feature").each ->
    $(".getdata").click (e) ->
      e.preventDefault()
      $(".laboratory_feature").submit()
  $("#block_description").each ->
    document.getElementById('block_description').innerHTML = '<h3>Features</h3>Each module available on this web-based service is protected by a customizable user privilege system.<br>Mouse over the blocks for further details.';
  