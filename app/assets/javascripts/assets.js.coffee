# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


breakpointDefinition =
  tablet: 1024
  phone: 480

window.merge_with_same_identifier = (orig, dest) ->
  ################################################################################
  # Iterate over a array, search fot itens with same _identifier property
  # merge properties and return a new array with itens merged
  # and with the same size of dest
  ################################################################################

  merged = dest.map (x) ->
    # Use the _identifier to select targed items to be merged
    orig_item = _.findWhere(orig, '_identifier': x._identifier.toString()) # Not sure why need to parse to String here..
    dest_item = x
    # Merge objects.
    # - When one is deleted on form, a new based on snippet is created, initialy disabled
    # - When on the for is updated, it dont get modified
    $.extend(dest_item, orig_item)
  return merged

jQuery ->
  $(".asset_datatables_feature").each ->

    ################################################################################
    # Assets datatables
    ################################################################################

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

    ################################################################################
    # Make possible to user change the asset
    ################################################################################

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

    ################################################################################
    # Get the template for asset fields, that is rendered on a hidden field
    ################################################################################

    asset_fields_template = $("#asset_template").data("fields")

    ################################################################################
    # Action to click on remove field
    ################################################################################

    $('form').on 'click', '.remove_fields', (event) ->
      that = this
      this.fieldset = $(this).closest('fieldset')
      this.position = $(that.fieldset).find(".position_map").val()
      service_id = that.fieldset.attr("obj-id")
      if service_id isnt ""
        $.getJSON("../" + that.fieldset.attr("obj-id") + ".json").done (data) ->
          snippets = data.spreadsheets.map (s) ->
            if s.table_json isnt null
              return s.table_json.choosen_snippets
          snippets_flat = _.reject(_.flatten(snippets), (x) -> x is undefined)
          res = _.find(snippets_flat, (s) ->
            return s.position.toString() is that.position.toString()
          )
          if res is undefined
            $(that).closest('fieldset').remove()
          else
            window.alert("The asset is being used on your spreadsheets. Try changing it instead of removing.")
      event.preventDefault()
      

    ################################################################################
    # Bind action do add asset by click on datatables item
    ################################################################################

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

  ################################################################################
  # Reclassification stuff
  ################################################################################

  $(".reclassification_feature").each ->

    ################################################################################
    # Possible ranges stored at element, retrieved from snippets
    ################################################################################

    avaliable_ranges = $("#asset_reclassification").data(avaliable_ranges)

    if (avaliable_ranges.avaliableRanges is null) or (avaliable_ranges.avaliableRanges is undefined) then return

    ################################################################################
    # Reshape data to fit on reclassifications
    ################################################################################
    avaliable_ranges_reshape = _.flatten(avaliable_ranges.avaliableRanges.map((x) ->
      name = x.value.name
      unit = x.value.unit
      return x.value.ranges.map( (y) ->
        obj = y
        obj.name = name
        obj.unit = unit
        return obj
      )
    )).map (x) ->
      x.enabled = false
      # Choose only some fields
      _.pick x, 'name', 'uncertainties', '_identifier', 'enabled', 'limits', 'unit'


    ################################################################################
    # Try to parse current data. It cal fail if it was just created
    ################################################################################
    try
      asset_reclassification_ranges = JSON.parse($("#asset_reclassification").val())
      merged = merge_with_same_identifier(asset_reclassification_ranges, avaliable_ranges_reshape)
      $("#asset_reclassification").val(JSON.stringify(merged))

    ################################################################################
    # Create reclassification editor
    ################################################################################

    create_json_editor("#asset_reclassification", window.reclassificationFormSchema, {template: 'swig'})