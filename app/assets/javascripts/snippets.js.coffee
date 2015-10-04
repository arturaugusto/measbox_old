# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->

  $(".spreadsheet_feature, .snippet_datatables_feature").each ->
    # If spreadsheet is on standalone mode
    window.standaloneMode = false

    # http://stackoverflow.com/questions/979975/how-to-get-the-value-from-the-url-parameter
    query_string = {}
    query = window.location.search.substring(1)
    vars = query.split('&')
    if query.length
      i = 0
      while i < vars.length
        pair = vars[i].split('=')
        # If first entry with this name
        if typeof query_string[pair[0]] == 'undefined'
          query_string[pair[0]] = decodeURIComponent(pair[1])
          # If second entry with this name
        else if typeof query_string[pair[0]] == 'string'
          arr = [
            query_string[pair[0]]
            decodeURIComponent(pair[1])
          ]
          query_string[pair[0]] = arr
          # If third or later entry with this name
        else
          query_string[pair[0]].push decodeURIComponent(pair[1])
        i++
      try
        content = JSON.parse LZString.decompressFromEncodedURIComponent query_string.data
        # Dfine as standalone
        if typeof content.data is "object" then window.standaloneMode = true
        window.standaloneContent = content
      catch e
        console.log e

  # Flavor map, for better readbility
  flvr = 
    asset: 1
    math: 2

  $(".snippet_datatables_feature").each ->
    that = this
    # Flavors to be fetched by default
    flavor = [flvr.asset, flvr.math]
    $.data($("#snippets")[0], "flavor", flavor )
    # Get only math model if its on spreadsheet edit
    $("#spreadsheet_table_json").each ->
      flavor = [flvr.math]
      $.data($("#snippets")[0], "flavor", flavor )
    # Get only asset model if its on spreadsheet edit
    $(".assets-holder").each ->
      flavor = [flvr.asset]
      $.data($("#snippets")[0], "flavor", flavor )

    breakpointDefinition =
      tablet: 1024
      phone: 480

    ################################################################################
    # Snippet datatable
    ################################################################################

    tableContainer = $('#snippets')

    if not standaloneMode
      window.snippetDataTable = tableContainer.dataTable
        responsive: true
        fnSetFilteringDelay: 2000
        pagingType: 'full_numbers'
        dom: "l<\"toolbar-snippets\">rtip" # To understand this crap, see http://datatables.net/reference/option/dom , the "f" was removed, as i'm using a custom search field
        sPaginationType: "bootstrap"
        bAutoWidth: false
        bStateSave: false
        bPaginate: true
        bProcessing: false
        bServerSide: true
        columnDefs: [
          orderable: false
          targets: 2
        ]
        sAjaxSource: $('#snippets').data('source')
        fnServerParams: (aoData) ->
          aoData.push
            name: "flavor"
            value: $.data($("#snippets")[0], "flavor" )
          # Mathematical Snippet como filtro dos snippets dos assets
          if $("#spreadsheet_table_json").data( "temp-data")
            func_tag_list = $("#spreadsheet_table_json").data( "temp-data").func_tag_list
            if func_tag_list isnt undefined
              aoData.push
                name: "func_tag_list"
                value: func_tag_list
          # Add pre tags, if some
          
          $("#pre_tags").each ->
            if $(this).val() isnt ""
              aoData.push 
                name: "pre_tags"
                value: $(this).val()
          # Show all users snippets if chebkbox is checked
          if $("#global_snippets").prop( "checked" ) is true
              aoData.push 
                name: "global_snippets"
                value: true

        fnPreDrawCallback: ->
        fnRowCallback: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
        fnDrawCallback: (oSettings) ->
          $(".snippet_chooser_feature").each ->

            ################################################################################
            # Modal with datatables, to choose math snippet on spreadsheet
            ################################################################################

            $(".math_snippet_chooser").click (event) ->
              event.preventDefault()
              s_id = $(this).attr("s_id")
              $.get "../../snippets/get_json?id=" + s_id, (data) ->
                console.log data
                # create a new reference to tags
                data.snippet.value._tag_list = data.tag_list
                # Definne id of snippet
                data.snippet.value._id = s_id
                spreadsheetEditorBuilder(data.snippet.value)
                $('#myModal').modal('hide')
              return
              
            ################################################################################
            # Modal with datatables, to add new element to choosen snippets, on spreadsheet form
            ################################################################################

            $(".asset_snippet_chooser").click (event) ->
              # Get selected instrument identifiaction
              s_id = $(this).attr("s_id")
              #identification = $("span.search_fields[active='true']").prev().text()
              #description = $("span.search_fields[active='true']").prev().prev().data("model")
              asset_id = $("span.search_fields[active='true']").parent().find(".asset_json_data").attr("asset_id")
              position = $("span.search_fields[active='true']").parent().find(".position_map").val()
              model_id = $("span.search_fields[active='true']").parent().find(".asset_json_data").data("json").model_id
              $.get "../../snippets/get_json?id=" + s_id + "&model_id=" + model_id + "&asset_id=" + asset_id, (data) ->
                # Alert that the asset is not avaliable
                # and ask to confirm using it
                if not data.asset.avaliable
                  confirm = window.confirm("Warning: The asset is flagged as unavaliable to use. Choose it anyway?")
                  if not confirm then return
                # build text for choosen snippet
                data.snippet.position = position
                data = filter_snippet_data(data)
                #data.snippet.label = description + " - " + data.tag_list
                #data.snippet.asset_id = asset_id
                #data.snippet.snippet_id = data.snippet.id
                #data.snippet.model_id = model_id
                snippetsDataArray = window.spreadsheetEditor.getEditor('root.choosen_snippets')
                snippetsDataArray.addRow(data.snippet)
              event.preventDefault()
              return # onclick

    ################################################################################
    # Listem to togglable snippets scope changer, to update datatables when toggle ocour
    ################################################################################

    $('#global_snippets').change ->
      snippetDataTable.fnDraw()

    ################################################################################
    # On Spreadsheet, check if it was created before, if not, open the modal so user
    # can choose the math snippet and than, create the editor
    ################################################################################

    $("#spreadsheet_table_json").each ->
      #$(".input-daterange").datepicker forceParse: false
      # Open modal
      table_json = $("#spreadsheet_table_json").val()
      if window.standaloneMode
        table_json = JSON.stringify window.standaloneContent.data
        $("#spreadsheet_table_json").val( table_json )
        $("#spreadsheet_spreadsheet_json").val( JSON.stringify standaloneContent.input )

      if (table_json is "") or (table_json is "{}")
        $('#myModal').modal('show')
      else
        spreadsheetEditorBuilder(JSON.parse(table_json).model)

    ################################################################################
    # Create tags field on datatables dom
    ################################################################################

    $("div.toolbar-snippets").html('
      <div id="snippets_filter" class="dataTables_filter">
        <label>
        Tag search:
        <input type="search" class="form-control input-sm" data-role="tagsinput" id="snippets_tags_filter" aria-controls="snippets">
        </label>
      </div>
    ');

    ################################################################################
    # Starting tags with typeahead
    # This is the default searchbox found on snippets index page 
    ################################################################################

    $("#snippets_tags_filter").tagsinput 
      tagClass: (item) -> return 'label label-default'
      typeahead:
        source: (query) ->
          $.get "../../snippets/autocomplete",
            tag: query
            flavor: $.data($("#snippets")[0], "flavor") # Search either math model or asset snippets
            global_snippets: $("#global_snippets").prop( "checked" ) # undefined if dont exist on page
          , ((data) ->
            return data
          )

    ################################################################################
    # Listen changes on tags field and perform the search on datatables
    ################################################################################

    $("#snippets_tags_filter,#snippet_model_list").on "change", ->
      searchString = $("#snippets_tags_filter").val()
      on_spreadsheet = $(".spreadsheet_feature").length
      search_flavor = $.data($("#snippets")[0], "flavor" )[0]
      # To avoid double request due table change when tag is dinamicaly added
      if not ( (searchString.length is 0) and (search_flavor is flvr.asset) and (on_spreadsheet) )
        tableContainer.fnFilter( searchString )

    ################################################################################        
    # The folowing action only takes place inside spreadsheet, when filtering snippets for
    # a specific asset and the pre_tags exists
    ################################################################################

    $("#pre_tags").each ->
      $("#snippets_tags_filter").on "itemRemoved", (event) ->
        tags = $("#pre_tags").val().split(/[\s,]+/)
        # If trying to remove pre tag, add it again
        if _.indexOf(tags, event.item) isnt -1
          $(this).tagsinput('add', event.item)


  ################################################################################        
  # Routines when a snippet datatable exists
  ################################################################################

  $(".snippet_feature").each ->

    ################################################################################        
    # On snippet editor, when math is choosen, hide tags for instruments models
    ################################################################################

    toggleModelList = ->

      # If snippet is already defined, show tags controls
      if $("#snippet_flavor").val() isnt ""
        $(".hidden_tags_input").toggle()

      if parseInt($("#snippet_flavor").val()) is flvr.math
        $(".snippet_model_list").hide()
        # remove all model tags
        # Algum efeito colateral comentar linha abaixo ???
        #$('#snippet_model_list').tagsinput('removeAll')
      else
        $(".snippet_model_list").show()

    toggleModelList()

    ################################################################################        
    # Set tags input
    ################################################################################
    
    $("#snippet_functionality_list").tagsinput
      tagClass: (item) -> return 'label label-info'
      typeahead:
        source: (query) ->
          $.get "../../snippets/autocomplete",
            tag: query
            skip_model: true
            flavor: [flvr.math] # asset snippets
          , ((data) ->
            return data
          )

    ################################################################################        
    # Form builders names
    ################################################################################

    $("#snippet_value").hide()
    formBuilders =
      setMathForm: () ->
        editor = create_json_editor("#snippet_value", window.mathFormSchema)
        editor    
      setAssetForm: () ->
        editor = create_json_editor("#snippet_value", window.assetFormSchema)
        editor
    # Map flavors
    flavors = 
      1: "setAssetForm"
      2: "setMathForm"

    editorIndex = $("#snippet_flavor").val()
    if editorIndex isnt ""
      $("input[type='submit']").prop('disabled', false)
      editor = formBuilders[ flavors[editorIndex] ]()
      #editor.setValue value
    else
      # Submit starts disable to avoid invalid json to be sent to server
      $("input[type='submit']").prop('disabled', true)

    ################################################################################        
    # Build editor on option change
    ################################################################################

    $("#snippet_flavor").on "change", (e) ->
      $(this).parent().parent().hide()
      $("input[type='submit']").prop('disabled', false)
      optionSelected = $("option:selected", this)
      valueSelected = @value
      toggleModelList()
      # Remove existing editors
      try
        editor.destroy()
      editor = formBuilders[ flavors[valueSelected] ]()
      return
