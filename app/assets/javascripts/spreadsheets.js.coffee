# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $(".spreadsheet_feature").each ->
    $(this).bind('ajax:success', (data, status, xhr) ->
      $.notify 'Changes saved!',
        className: 'success'
        globalPosition: 'top left'
        style: 'bootstrap'
        showAnimation: 'fadeIn'
        hideAnimation: 'fadeOut'
      return
    ).bind 'ajax:error', (xhr, status, error) ->
      alert("Error on saving form. Try again later. If error presists, contact the support.")
      return

    ht = $('#handsontable').handsontable('getInstance')
    sync_timeout_id = 0
    timeout_sync = () ->
      clearTimeout(sync_timeout_id)
      sync_timeout_id = setTimeout ( ->
        syncHTSnippets(ht)
      ), 1000
    save_timeout_id = 0
    timeout_save = () ->
      clearTimeout(save_timeout_id)
      save_timeout_id = setTimeout ( ->
        autoSave()
      ), 5000
    # Set ROUND_HALF_EVEN
    Big.RM = 2
    # Col that holds the UUT value
    point_value_key = "UUT"
    # Get precision of number. requires Big Decimal
    # Remove prefix and trim string with number
    remove_text = (str) ->
      n_str = str.trim().replace(/([a-zA-Z]){1,2}$/g, (x) ->
          k = x
          ""
        ).trim()

    window.auxFormatingFunctions =
      precision: (x) ->
        x = remove_text(x.toString())
        return x.split(/^[0\s\D]*|[\.]/).join("").length
      resolution: (x) ->
        x = remove_text(x.toString())
        x_split = x.split(".")
        if x_split.length is 1
          return 0
        else
          return x_split[1].length

    window.get_prefix = (k) ->
      prefixes =
        Y: 1000000000000000000000000
        Z: 1000000000000000000000
        E: 1000000000000000000
        P: 1000000000000000
        T: 1000000000000
        G: 1000000000
        M: 1000000
        k: 1000
        h: 100
        da: 10
        d: 0.1
        c: 0.01
        m: 0.001
        u: 0.000001
        n: 0.000000001
        p: 0.000000000001
        f: 0.000000000000001
        a: 0.000000000000000001
        z: 0.000000000000000000001
        y: 0.000000000000000000000001
      k_val = (if prefixes[k] is undefined then 1 else prefixes[k])

    parse_readout = (str) ->
      k = undefined
      n_str = undefined
      if typeof str is "number"
        n_str = str
      else if (str is null) or (str is undefined)
        n_str = 0
      else
        n_str = str.trim().replace(/([a-zA-Z]){1,2}$/g, (x) ->
          k = x
          ""
        )
      k_val = get_prefix(k)
      parseFloat(n_str) * k_val

    sortByKey = (array, key) ->
      array.sort (a, b) ->
        x = parse_readout(a[key])
        y = parse_readout(b[key])
        (if (x < y) then -1 else ((if (x > y) then 1 else 0)))

    window.chosenAssetsEditor = new JSONEditor document.getElementById('chosenAssetsHolder'),
        theme: "bootstrap3"
        iconlib: "bootstrap3"
        disable_collapse: false
        disable_array_add: true
        schema:
          type: "object"
          title: "Chosen snippets"
          properties:
            snippets:
              type: "array"
              format: "tabs"
              title: "snippets"
              items:
                type: "object"
                title: "snippet"
                headerTemplate: "{{ self.label }}"
                options:
                  collapsed: true
                properties:
                  label:
                    type: "string"
                    title: "Label"
                    format: "text"
                    propertyOrder: 1
                  asset_id:
                    type: "string"
                    options: {"hidden": true}
                    propertyOrder: 2
                  snippet_id:
                    type: "string"
                    options: {"hidden": true}
                    propertyOrder: 3
                  position:
                    type: "string"
                    options: {"hidden": true}
                    propertyOrder: 4
                  value:
                    type: "object"
                    title: "Value"
                    options:
                      collapsed: true
                    propertyOrder: 5
                    properties:
                      ranges: window.rangesSchema.ranges    

    # Update handsontable text when the label is changed on snippets data
    syncWithAssetsEditor = (ht) ->
      ht_changes = []
      asset_snippets_editor = chosenAssetsEditor.getValue("root.snippets").snippets
      if $('.table-json').data("temp-data").lookup isnt undefined
        prev_lookup = $('.table-json').data("temp-data").lookup
        for l, l_index in prev_lookup
          row = prev_lookup[l_index].row_index
          col = prev_lookup[l_index].col_index
          ht_label = ht.getDataAtCell(row, col)
          changed_asset_snippet = asset_snippets_editor[prev_lookup[l_index].snippet_index]
          # Compare items, if differents, update ht
          if (changed_asset_snippet isnt undefined) and (ht_label isnt changed_asset_snippet.label)
            ht_changes.push [row, col, changed_asset_snippet.label]
        if ht_changes.length
          ht.setDataAtCell(ht_changes)

    # Wait editor to full load
    chosenAssetsEditor.on "ready", ->
      #chosenAssetsEditor.watch "root.snippets", ->
      chosenAssetsEditor.on "change", ->
        ht = $('#handsontable').handsontable('getInstance')
        if ht isnt undefined
          syncWithAssetsEditor(ht)
          #syncHTSnippets(ht)

    ######################
    syncHTSnippets = (ht) ->
      # Check if temp snippets data already exists
      if typeof $('.table-json').data("temp-data").asset_snippets is undefined
        # Call autosave to ensure all data and temp data is avaliable
        autoSave()
      # Take a look inside handsontable settings, 
      # and see witch fields are autocomplete
      mapAutocompletFields = (ht) ->
        col_to_verify = []
        ht.getSettings().columns.map (c, i) ->
          col_to_verify.push i  if c.type is "autocomplete"
        return col_to_verify
      col_to_verify = mapAutocompletFields(ht)
      # Procedure variables
      variables = $('.table-json').data("temp-data").value.variables
      # Where calculated data col starts?
      # table_offset holds this value
      table_offset = 0
      # row point val
      point_vals = []
      # Update table offset value, based on where UUT defined var is found
      # on handsontable. Also set the point val, that is the first value right the UUT autocomplete field
      iterateOverAutocomplets = () ->
        # First, set a array with the point value.
        # The point value is the readout of the UUT col
        replications = $('.table-json').data("temp-data").value.replications
        for v, i in variables
          # invisible cols count only one
          if v.kind.indexOf('Invisible') >= 0
            if (v.kind.indexOf('UUT') >= 0)
              # Reach the col with values
              point_vals = ht.getDataAtCol(table_offset)
            table_offset = table_offset + 1
          else
            table_offset = table_offset + replications + 1
            if (v.kind.indexOf('UUT') >= 0)
              # Reach the col with values
              point_vals = ht.getDataAtCol(table_offset-replications)

      iterateOverAutocomplets()
      # lookuap array to handsontable rows and assets snippets
      lookup = []
      # Influence quantities
      influence_quantities = $('.table-json').data("temp-data").value.influence_quantities
      # Errors list for evaluation
      error_list = []

      determineRangeReclass = (range, expr_params, asset_label) ->
        reklass_index = null
        for reklass, k in range.reclassifications
          conditions_expr = reklass.condition
          result = try expr.parse(conditions_expr, expr_params)
          catch e then error_list.push('Reclassification condition: "' + conditions_expr + '"\nRange name: "' + range.name + '"\nSnippet label: "' + asset_label + '"\n' + e.message ) #; finally 
          # Valid reclassification found
          if result
            reklass_index = k
            break
        return reklass_index
      # Get snippets data from json-editor
      asset_snippets_editor = chosenAssetsEditor.getValue("root.snippets").snippets

      # Iterate to determine the correct range
      determineSnippetRange = (asset_map, var_name, row_i) ->
        range_index = null
        reklass_index = null
        error = null
        asset = asset_snippets_editor[asset_map.snippet_index]
        if asset isnt undefined
          # Params that will be exported to user defined expresion evaluation on browser
          expr_params = {}
          # Get readout
          expr_params.readout = parse_readout(asset_map.first_readout)
          # Get point value
          if (typeof(point_vals[asset_map.row_index]) isnt "undefined") and (point_vals[asset_map.row_index] isnt null)
            expr_params.point = parse_readout(point_vals[asset_map.row_index].toString())
          else 
            expr_params.point = 0
          # set influence quantities for current row
          for iq, iq_index in influence_quantities
            iq_val = ht.getDataAtCell(asset_map.row_index, table_offset+iq_index)
            expr_params[iq.name] = iq_val
          # Get deeper asset information from DOM
          asset_json_el = $(".asset_json_data[asset_id='" + asset.asset_id + "']")
          if typeof(asset_json_el[0]) isnt undefined
            asset_data = JSON.parse(asset_json_el.attr("data-json"))
            expr_params.asset = asset_data
          # Iterate over ranges inside asset
          for range, range_i in asset.value.ranges
            # Define the params, adding some aliases
            expr_params.range = range
            expr_params.range_start = range.limits.start
            expr_params.range_end = range.limits.end
            expr_params.full_scale = range.limits.fullscale
            expr_params.is_meas = if range.kind is "Measurement" then 1 else 0
            expr_params.is_source = if range.kind is "Source" then 1 else 0
            expr_params.is_fixed = if range.kind is "Fixed" then 1 else 0
            # Get the conditions of the range and parse to check if this range is for this point
            conditions_expr = range.limits.autorange_conditions
            result = try expr.parse(conditions_expr, expr_params)
            catch e then error_list.push('Autorange expression: "' + conditions_expr + '"\nRange name: "' + range.name + '"\nSnippet label: "' + asset.label + '"\n' + e.message ) #; finally 
            if result
              range_index = range_i
              reklass_index = determineRangeReclass(range, expr_params, asset.label)
              break
          # No suitable range found, show error
          if range_index is null
            error = "No suitable range found: line " + (row_i+1).toString() + ", variable " + var_name
        return {"range_index": range_index, "reklass_index": reklass_index, "error": error}

      # The next line show a bug on handsontable that I cant get the value changed imediatly before update it
      #ht = $('#handsontable').handsontable('getInstance');ht.setDataAtCell(0,0,"aaa");x=ht.getDataAtCol(0);console.log(x)
      setTimeout (->

        # return a array that contains the index of asset used by each autocomplete field,
        # the var name and row index
        compareAutocompletesToAssetsSnippets = () ->
          for col_i, col_i_index in col_to_verify
            col_readout = ht.getDataAtCol(col_i+1)
            row_data = ht.getDataAtCol(col_i)
            # Ger var name. The vartiables array is index the same order handsontable
            # so we can use col_i_index to access it
            if variables[col_i_index] isnt undefined
              var_name = variables[col_i_index].name
            else
              var_name = null
            for autocomplete_label, row_i in row_data
              if autocomplete_label isnt null
                asset_map = {}
                match = _.findWhere(asset_snippets_editor, {label:autocomplete_label.trim()})
                if match is undefined
                  asset_map["snippet_index"] = null
                else
                  match_i = _.indexOf(asset_snippets_editor, match)
                  asset_map["snippet_index"] = match_i
                asset_map["var"] = var_name
                asset_map["row_index"] = row_i
                asset_map["col_index"] = col_i
                asset_map["first_readout"] = ht.getDataAtCell(row_i, col_i+1)
                # Determine range and reclass indexes
                range_and_reklass_indexes = determineSnippetRange(asset_map, var_name, row_i)
                asset_map["range_index"] = range_and_reklass_indexes.range_index
                asset_map["reklass_index"] = range_and_reklass_indexes.reklass_index
                asset_map["error"] = range_and_reklass_indexes.error
                lookup.push asset_map
          return lookup
        lookup = compareAutocompletesToAssetsSnippets()
        # Check for autorange and parse errors
        $(lookup).each ->
          if this.error isnt null
            error_list.push(this.error)
        if error_list.length
          error_msg = error_list[0]
          $("#error_messages").text(error_msg)
          $("#error_messages").show()
        else
          $("#error_messages").hide()
          
        # Send changes to handsontable!
        #if data_to_change.length
        #  ht.setDataAtCell(data_to_change)
        # sync temp data on element
        data = $('.table-json').data("temp-data")

        # Set some keys
        uut_data = do_uut_lookup(data)
        uut_name = uut_data.uut_name
        uut_units = uut_data.uut_units
        uut_prefixes = uut_data.uut_prefixes
        
        data.table_data.map (x,i) ->
          if (x[point_value_key] isnt null) and (x[point_value_key] isnt undefined)
            x.readout = get_prefix(uut_prefixes[i])*x[point_value_key]
            x._prefix = uut_prefixes[i]
            x._unit = uut_units[i]

        data.asset_snippets = chosenAssetsEditor.getValue()
        data.lookup = lookup
        data.uut_ids = uut_data.uut_ids
        data.table_offset = table_offset
        data.assets = assets_json
        $(".table-json").data( "temp-data", data )
        ht.render()
      ), 100



    ###################
    # Load assets data on assets_json GLOBAL var
    assets_json = {}
    $(".asset_json_data").each ->
      asset_json = JSON.parse $(this).attr("data-json")
      assets_json[asset_json.id] = asset_json
      assets_json[asset_json.id]["position"] = $(this).attr("position")

    # This helps to draw correctly the handsontable when we come back to spreadsheet tab
    $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
      if $(e.target).text() is "Spreadsheet"
        ht = $('#handsontable').handsontable('getInstance')
        ht.render()
      return

    # actiion to search icon for the assets    
    $(".search_fields").click (e) ->
      # Set a attribute on clicked element
      # But first, clear all
      $("span.search_fields[active='true']").each ->
        $(this).attr("active", false)
      $(this).attr("active", true)
      # Reach tag list
      tag_list = $(this).parent().prev().val().split(/[\s,]+/).join() # This will trim the tags
      # Fill hidden with tags
      $("#pre_tags").val(tag_list)
      # Removes all tags
      $("#snippets_tags_filter").tagsinput('removeAll')
      # Add tags
      $("#snippets_tags_filter").tagsinput('add', tag_list)
      # Avoid removing pre tags from search box
      flavor = ["1"]
      $.data($("#snippets")[0], "flavor", flavor )
      snippetDataTable.fnDraw()
      $('#myModal').modal('toggle')

    # Action to submit form
    autoSave = (cb = false) ->
      #$("#snippets_tags_filter").tagsinput('removeAll')
      ht = $('#handsontable').handsontable('getInstance')
      # If not inicialized, ask user to choose the spreadsheet model
      if typeof ht is "undefined"
        # Ensure that the datatable is seted to math model filtering
        if $.data($("#snippets")[0], "flavor").toString() is "1"
          flavor = ["2"]
          $.data($("#snippets")[0], "flavor", flavor )
          snippetDataTable.fnDraw()
        $('#myModal').modal('show')
        return
      # Get data from dom
      data = $('.table-json').data("temp-data")
      # Update it with handsontable data
      data.table_data = ht.getData()
      # Updata now with asset-snippets data
      data.asset_snippets = chosenAssetsEditor.getValue()
      # Store assets data, it will always be overwitten with fresh data
      data.assets = assets_json
      # Store it again, updated
      $(".table-json").data( "temp-data", data )
      # Convert to string and store it on the hidden field, 
      # so rails can save to database
      $(".table-json").val( JSON.stringify(data) )
      # Submit the form
      $(".spreadsheet_feature").submit()
      # If callback function sent, call it!
      if cb
        cb()

    assyncUpdate = (id, i) ->
      $.get "../../snippets/get_json?id=" + id, (data) ->
        # Finaly, update the data
        chosenAssetsEditor.getEditor( "root.snippets."+i.toString()+".value.ranges" ).setValue(data.snippet.value.ranges)
    # This action is useful to user update the assets on the snippets editor when 
    # they are changed at the service
    $("#refresh_snippets").click (e) ->
      e.preventDefault()
      snippetsEditor = chosenAssetsEditor.getEditor("root.snippets")
      snippets = snippetsEditor.getValue()
      service_assets = $(".asset_json_data")
      for snippet, i in snippets
        $(".position_map[value='" + snippet.position + "']").each ->
          $(snippet).attr( "asset_id", $(this).attr("asset_id") )
          # Update asset_info
          chosenAssetsEditor.getEditor( "root.snippets."+i.toString() ).setValue(snippet)
          assyncUpdate(snippet.snippet_id, i)
    # Button click      
    $(".getdata").click (e) ->
      e.preventDefault()
      autoSave()

    window.ocpuSend = () ->
      ht = $('#handsontable').handsontable('getInstance')
      json = $('.table-json').data("temp-data")
      # Get handsontable instance
      # If already defined, get current col headers
      oldColHeaders = _.keys(json.table_data[0])
      colHeaders = ht.getColHeader()
      # Remove unused colHeaders
      if oldColHeaders.length
        colHeadersDiff = _.difference oldColHeaders, colHeaders
        #console.log "Omiting old cols: " + colHeadersDiff
        json.table_data = json.table_data.map (x) ->
          _.omit x, colHeadersDiff
      #console.log json.table_data
      oc = json.value.output_columns
      fmt_oper = json.value.format_operations
      #because identity is in base
      ocpu.seturl "//public.opencpu.org/ocpu/library/base/R"
      #arguments
      mysnippet = new ocpu.Snippet($(".table-json").data( "temp-data").value.script)
      #perform the request
      req = ocpu.call("identity",
        x: mysnippet
      , (session) ->
        console.log "***"
        console.log session
        ocpu.seturl session.loc + "R"
        req = ocpu.call("main",
          object: json
        , (session) ->
          session.getObject ((result) ->
            uut_data = do_uut_lookup($(".table-json").data("temp-data"))
            uut_prefixes = uut_data.uut_prefixes
            # Map to array of arrays to 
            # feed handsontable
            outData = result.data.map (x, ht_line) ->
              for fmt in fmt_oper
                # remove + sign at begining of string and convert to Big
                # Removing the + avoid problems with the Big library
                num = new Big(x[fmt.output_column].toString().match(/[^\s+].*/)[0])
                
                # Scale value with prefix
                prefix = uut_prefixes[ht_line].trim()
                k = get_prefix(prefix)
                num = num.div(k)
                
                # Call function and apply string arguments converted to array
                num = Big.prototype[fmt.operation].apply( num, (fmt.argument).split(",").map (str_arg) -> 
                  if str_arg.length
                    # Check if is NOT number
                    if isNaN(str_arg)
                      splt_string = str_arg.split(".")
                      if splt_string.length > 1
                        col_title = splt_string[0].trim()
                        # Search by col title
                        HT_value = x[col_title]
                        # if undefined, look on json
                        if HT_value is undefined
                          HT_value = json.table_data[ht_line][col_title]
                        # the second slice is the function to be called
                        return auxFormatingFunctions[splt_string[1].trim()](HT_value)
                    else
                      return parseFloat(str_arg)
                  else
                    return ""
                )
                res = num.toString()
                x[fmt.output_column] = res
              oc.map (y) ->
                return x[y.name]
            firstOutIndex = ht.propToCol(oc[0].name)
            ht.populateFromArray(0, firstOutIndex, outData)
            # Sync details
            temp_data = $('.table-json').data("temp-data")
            temp_data.details = result.details
            $(".table-json").data( "temp-data", temp_data )
            return
          ),
            digits: 10
          return 
        )
      )
      
      #if R returns an error, alert the error message
      req.fail ->
        alert "Server error: " + req.responseText
        return
      req.always ->
        #$("button").removeAttr "disabled"
        return
      return

    window.buildHandsontable = (data, func_tag_list = false) ->
      columns = []
      colHeaders = []
      dataSchema = {}
      selectedCell = {}
      # Build assets-snippets editor, if exists
      if typeof data.asset_snippets isnt "undefined"
        chosenAssetsEditor.setValue data.asset_snippets

      # Set color to cols acording to asset defined schema
      colorRenderer = (instance, td, row, col, prop, value, cellProperties) ->
        Handsontable.renderers.TextRenderer.apply this, arguments
        $(td).css background: columns[col]["color"]
        return

      # Function to add cols to datatable
      addCol = (headerTxt, color, options = null) ->
        dataSchema[headerTxt] = null
        colHeaders.push headerTxt
        columns.push 
          data: headerTxt
          color: color
          renderer: colorRenderer
      # Map variable names to replications quantity
      data.value.variables.map (v) ->
        # Get the index of col added to hold the snippet autocomplete  
        colCount = addCol(v.name + " Snippet", v.color, true)
        # Add the autocomplete
        col = columns[colCount-1]
        col.type = 'autocomplete'
        col.source = (query, process) ->
          autocomplete_label_list = chosenAssetsEditor.getEditor("root.snippets").getValue().map (s) ->
            s.label.trim()
          process autocomplete_label_list
          return        
        col.strict = true
        col.allowInvalid = true
        # Add cols for input variables, the number of replication defined
        if v.kind.indexOf('Invisible') < 0
          i = 0
          while i < data.value.replications
            i++
            colHeader = v.name + " " + i.toString()
            addCol(colHeader, v.color, { type: 'autocomplete', source: [] } )
        return
      # Set influence quantities cols
      data.value.influence_quantities.map (iq) ->
        addCol(iq.name, iq.color, true)
      data.value.output_columns.map (iq) ->
        addCol(iq.name, iq.color, true)
      # build table
      $container = $("#handsontable")
      #Handsontable.Dom.addClass($container, 'table')
      $container.handsontable
        data: data.table_data
        dataSchema: dataSchema
        colHeaders: colHeaders
        autoColumnSize: true
        columns: columns
        contextMenu: true
        contextMenu:
          callback: (key, options) ->
            if key is "plot"
              chart_data = []
              ht = $('#handsontable').handsontable('getInstance')
              selection = ht.getSelected()
              chart_data = ht.getData()

              # Map units for each row uut
              uut_units = $('.table-json').data('temp-data').table_data.map((x) ->
                x._unit
              )
              # Remove the last undefined row
              uut_units.splice(-1,1)

              # Apply filter to data, alow only valid entries
              chart_data = _.filter(chart_data, (a) -> a.U isnt null)

              chart_data = sortByKey(chart_data, "readout")

              # Define if label for plot is a uniq unit, or if its mixed
              if _.uniq(uut_units).length is 1
                plot_unit = uut_units[0].toString()
              else
                plot_unit = ""
              # Get influence quantities to create labels for chart
              infl = $(".table-json").data("temp-data").value.influence_quantities.map((x) ->
                x.name
              )
              # Join inflence quantities from each row to a array of strings
              infl_join = chart_data.map((x) ->
                infl.map (y) ->
                  x[y]
              ).map (x) ->
                x.toString()
              infl_join_uniq = _.uniq(infl_join)

              # Map to create series for points and errors
              series_points = infl_join_uniq.map (x) ->
                name: x
                type: "spline"
                data: []
                tooltip:
                  pointFormat: "<span style=\"font-weight: bold; color: {series.color}\">{series.name}</span>, error: <b>{point.y}</b>, "                
              series_error = infl_join_uniq.map (x) ->
                name: x + " error"
                type: "errorbar"
                data: []
                tooltip:
                  pointFormat: "U: <b>{point.low}</b> to <b>{point.high}</b><br/>"
              series = []

              series = $.map(series_points, (v, i) ->
                [
                  v
                  series_error[i]
                ]
              )
              # Feed series object with handsontable data
              for infl_item, infl_i in infl_join
                prefix_val = get_prefix(chart_data[infl_i]._prefix)
                data_i = infl_join_uniq.indexOf(infl_item)
                error = new Big(chart_data[infl_i].e).times(prefix_val)
                U = new Big(chart_data[infl_i].U).times(prefix_val)
                UUT_readout = new Big(chart_data[infl_i][point_value_key]).times(prefix_val)
                lower_limit = parseFloat(error.minus(U))
                upper_limit = parseFloat(error.plus(U))
                # Point
                series[data_i*2].data.push([parseFloat(UUT_readout), parseFloat(error)])
                # Error bars
                series[data_i*2+1].data.push([parseFloat(UUT_readout), lower_limit, upper_limit])
                # individual colors
                color = Highcharts.getOptions().colors[data_i]
                series[data_i*2].color = color
                series[data_i*2+1].color = color
              $("#chart-container").html("")
              # Show modal
              $('#chartModal').modal('toggle')
              $("#chart-container").highcharts
                credits:
                  enabled: false
                chart:
                  zoomType: "xy"
                title:
                  text: "Error vs Calibration Point"
                subtitle:
                  text: "Series for <b> " + infl.toString() + "</b> influence quantities:"
                  floating: true,
                  align: 'center',
                  x: -10,
                  verticalAlign: 'bottom',
                  y: -20
                yAxis: [ # Primary yAxis
                  labels:
                    format: "{value} " + plot_unit
                    style:
                      color: Highcharts.getOptions().colors[1]
                  title:
                    text: "Error"
                    style:
                      color: Highcharts.getOptions().colors[1]
                ]
                tooltip:
                  headerFormat: "{point.key} " + plot_unit + "<br/>",
                  valueSuffix: " " + plot_unit
                  shared: true
                series: series
            if key is "save"
              # Save spreadsheet
              autoSave()
            if key is "calc"
              # Save spreadsheet and send ocpuSend function as callback
              autoSave( ocpuSend )
            if key is "update"
              if confirm "Do you want to update this spreadsheet to the latest version?"
                setTimeout (->
                  $.get "../../snippets/get_json?id=" + $('.table-json').data("temp-data").id, (data) ->
                    buildHandsontable(data.snippet, data.tag_list)
                ), 100
            if key is "details"
              row_detail = $('.table-json').data("temp-data").details[selectedCell.row]
              if typeof row_detail isnt "undefined"
                details_body = $('#detailsModal').find(".modal-body")
                details_body.html("")
                for detail, i in row_detail
                  # Check if details is corrected formated
                  if (typeof detail.type isnt "undefined") and (typeof detail.value isnt "undefined")
                    content = ""
                    if detail.type[0] is "raw"
                      content = detail.value[0]
                    if detail.type[0] is "table"
                      content = '<table class="table table-striped table-bordered" cellspacing="0" width="100%"></table>'
                    new_div = $('<div/>',
                        id: 'detail_' + i,
                        #className: 'foobar',
                        html: content
                    )
                    details_body.append(new_div)
                    # Init datatables if is table
                    if detail.type[0] is "table"
                      colnames = []
                      # Get colnames from the key of json object
                      colnames = $.map(detail.value[0], (k, i) ->
                        return {"title": i}
                      )
                      # Map values to array
                      data_set = detail.value.map (x) ->
                        $.map x, (v, i) -> [v]
                      $(new_div).find("table").dataTable
                        "data": data_set
                        "columns": colnames
                # Show modal
                $('#detailsModal').modal('toggle')
            return
          items:
            row_above:
              disabled: ->
                #if first row, disable this option
                $("#handsontable").handsontable("getSelected")[0] is 0
            row_below: {}
            hsep1: "---------"
            remove_row: {}
            hsep2: "---------"
            plot:
              name: "Chart"            
            details:
              name: "Details"
            update:
              name: "Update"
            save:
              name: "Save"
            calc:
              name: "Calculate"
        afterChange: (changes, source) ->
          if source isnt "loadData"
            timeout_sync()
            timeout_save()
        afterOnCellMouseDown: (event, coords, TD) ->
          selectedCell = coords
        minSpareRows: 1
      # Set the functionality tag to data
      if func_tag_list
        data.func_tag_list = func_tag_list
      # Save data to table_json hidden input. Maybe change this to use localstorage on the future?
      $(".table-json").data( "temp-data", data )
      syncHTSnippets($container.handsontable('getInstance'))
    # Listen for changes on editor, and labels to be used