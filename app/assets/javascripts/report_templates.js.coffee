# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->

  $(".report_template_feature").each ->

    $(".getdata").click (e) ->
      e.preventDefault()
      $(".report_template_feature").submit()

    create_json_editor("#report_template_pdf_options", window.pdfOptionsSchema)

    #md_editor_create($('#editor'), $("#report_template_value"))