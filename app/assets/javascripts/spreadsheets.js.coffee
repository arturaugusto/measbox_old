# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->

  ################################################################################
  # Get prefix aux func
  ################################################################################

  window.prefix_val = (k) ->
    window.afterChangeTimeoutID = 0
    prefixes =
      'Y': 1000000000000000000000000
      'Z': 1000000000000000000000
      'E': 1000000000000000000
      'P': 1000000000000000
      'T': 1000000000000
      'G': 1000000000
      'M': 1000000
      'k': 1000
      'h': 100
      'da': 10
      'd': 0.1
      'c': 0.01
      'm': 0.001
      'u': 0.000001
      'n': 0.000000001
      'p': 0.000000000001
      'f': 0.000000000000001
      'a': 0.000000000000000001
      'z': 0.000000000000000000001
      'y': 0.000000000000000000000001
    k_val = if prefixes[k] == undefined then 1 else prefixes[k]

  window.reject_non_numbers = (list) ->
    _.reject(list, (n) ->
      return (n is undefined) or (n is null) or (n is NaN) or (n is "")
    ) 


  # Custom colors to Highcharts
  Highcharts.setOptions(
    colors: ['#058DC7', '#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
  )

  # Custom symbol to Highcharts
  Highcharts.SVGRenderer.prototype.symbols.cross = (x, y, w, h) ->
    return ['M', x, y, 'L', x + w, y + h, 'M', x + w, y, 'L', x, y + h, 'z']


  ################################################################################
  # Extend mathjs to post-processing functions
  ################################################################################

  
  window._convert_if_not_big_num = (x) ->
    if typeof x isnt "object"
      return new Decimal(parseFloat(x).toPrecision(15))
    else
      return x
  math.import(

    fmt_to_precision: (x, sd) ->
      x = window._convert_if_not_big_num(x)
      return x.toPrecision(sd)

    precision: (x, include_zeros) ->
      x = window._convert_if_not_big_num(x)
      return x.precision(include_zeros).toString()

    decimal_places: (x) ->
      if typeof x is "string"
        # This solve the problem with Decimal type to get its decimal places when ocours
        # number like 0.010 . In this case, it returns the decimal places of 2 instead of 3 that is desired.
        # Replacing all numbers to 1, we can get 1.111, and return the decimal places of 3
        x = x.replace(/[0-9]/g, "1")
      x = window._convert_if_not_big_num(x)
      return x.decimalPlaces()

    fmt_to_decimal_places: (x, dp) ->
      x = window._convert_if_not_big_num(x)
      return x.toDecimalPlaces(dp).toString()

    fmt_to_fixed: (x, n) ->
      x = window._convert_if_not_big_num(x)
      return x.toFixed(n).toString()

    prefix_val: prefix_val

    console: (x) ->
      console.log(x)
  )

  # Import jStat pdfs to mathjs
  dists_to_import = {}
  ('beta centralF cauchy chisquare exponential gamma invgamma kumaraswamy ' + \
  'lognormal noncentralt normal pareto studentt weibull uniform binomial ' + \
  'negbin hypgeom poisson triangular').split(' ').map( (dist_name) ->
    sample_fn = jStat[dist_name].sample
    if sample_fn isnt undefined
      dists_to_import[dist_name] = jStat[dist_name].sample
  )
  math.import(dists_to_import);

  ###
  render_hot_fix = () ->
    #window.hot.hide()
    window.hot.render()
    #setTimeout (->
    #  $("#hot_container").fadeIn()
    #), 0
    
  # Fix unformated hot when math model change
  $(".nav-tabs a").click (e) ->
    e.preventDefault()
    render_hot_fix()
  ###

  # Spreadsheet specific
  $(".spreadsheet_feature").each ->

    # Fix chart positioning on bootstrap modal
    # data chart:
    $('#chart').on 'show.bs.modal', ->
      $('#chart_container').css 'visibility', 'hidden'
      return
    $('#chart').on 'shown.bs.modal', ->
      $('#chart_container').css 'visibility', 'initial'
      chart = $('#chart_container').highcharts()
      chart.reflow()
      return
    # Monte Carlo
    $('#mcPlot').on 'show.bs.modal', ->
      $('#mc_container').css 'visibility', 'hidden'
      return
    $('#mcPlot').on 'shown.bs.modal', ->
      $('#mc_container').css 'visibility', 'initial'
      chart = $('#mc_container').highcharts()
      chart.reflow()
      return


    $("#spreadsheet_tag_list").tagsinput


    ################################################################################
    # Init uncertanties datatables
    ################################################################################

    window.unc_table = $("#uncertanties_table").dataTable
      #sDom: 'TRr<"inline"l> <"inline"f>t<"inline"p><"inline"i>'
      sDom: 'TRr t<"inline"p><"inline"i>'
      data: []
      columns: [
        { "title": "Var", "class": "var_col" }
        { "title": "Unit" }
        { "title": "Source" }
        { "title": "Type" }
        { "title": "Input", "class": "center" }
        { "title": "Dist.", "class": "center" }
        { "title": "Std. Unc.", "class": "center" }
        { "title": "Coef.", "class": "center" }
        { "title": "Contribution", "class": "center" }
        { "title": "Graph.", "class": "center" }
      ]
      aoColumnDefs: [
        {
          aTargets:[0]
          fnCreatedCell: (nTd, sData, oData, iRow, iCol) ->
            color = _.findWhere(
              spreadsheetEditor.getEditor("root.model.variables").getValue(), 
              {"name": sData}).color
            if color isnt undefined
              $(nTd).closest('.var_col').css('background-color', color)
              #$(nTd).closest('.var_col').css({'color': color, 'text-shadow': '0 1px 0 rgba(255, 255, 255, 0.4);'})
              #$(nTd).closest('.var_col').css({"text-align": "center;", "padding": "40px 0;", "text-shadow": "0 1px 0 rgba(255, 255, 255, 0.4);"})
        }                    
      ]

      #sPaginationType: "bootstrap"
      #responsive: true # this true makes thinks a bit slower...
      #pagingType: 'full_numbers'
      bAutoWidth: false

    ################################################################################
    # Percent to RGP, borrowed from http://stackoverflow.com/questions/340209/generate-colors-between-red-and-green-for-a-power-meter/340214#340214
    ################################################################################

    percentToRGB = (percent) ->
      if percent == 100
        percent = 99
      r = undefined
      g = undefined
      b = undefined
      if percent < 50
        # green to yellow
        r = Math.floor(255 * percent / 50)
        g = 255
      else
        # yellow to red
        r = 255
        g = Math.floor(255 * (50 - (percent % 50)) / 50)
      b = 0
      'rgb(' + r + ',' + g + ',' + b + ')'


    get_chart_unit = (data) ->
      # Get used unit list
      units = _.uniq data.map (x) ->
        return x.uut_unit
      
      # reject undefined      
      units = _.reject( units,  (x) ->
        return x is undefined
      )
      
      # If multiple units exixts, use blank
      if units.length > 0
        _chart_unit = " " + units[0]
      else
        _chart_unit = ""
      return _chart_unit

    ################################################################################
    # Set series and tooltip handlers for charts
    ################################################################################

    set_chart_series = (data, x_key, x_key_parser) ->
      _chart_unit = get_chart_unit(data)

      # Group by serie name
      series_groups = _.groupBy(data, (x) -> 
        x.serie_name
      ) 

      series = []
      _.keys(series_groups).map((serie_name) ->
        point = series_groups[serie_name].map((p) ->
          return [x_key_parser(p[x_key]), p.y]
        )
        series.push
          name: serie_name
          type: 'spline'
          data: point
          tooltip:
            #headerFormat: '<b>{series.name}</b><br>'
            headerFormat: ''
            pointFormatter: () ->
              point = ''
              # Solve bug when showing trend chart
              if this.x < 1e10
                point = '<b>Point:</b> '  + this.x.toExponential(2) + _chart_unit
              else
                d = new Date(this.x)
                point = '<b>Date:</b> ' + d.toDateString()
              return point + ' <b>Error:</b> ' + this.y.toExponential(2) + _chart_unit + '<br/>'

        point_error = series_groups[serie_name].map((p) ->
          return [x_key_parser(p[x_key]), p.y - (p.U), p.y + (p.U)]
        )


        series.push
          name: serie_name + ' error'
          type: 'errorbar'
          data: point_error
          tooltip:
            #headerFormat: '<b>{series.name}</b><br>'
            headerFormat: ''
            pointFormatter: () ->
              return '<b>U:</b> ' + this.low.toExponential(2) +  '<b> .. </b>' +  this.high.toExponential(2) + _chart_unit + '<br>'

        upper_point_mpe = series_groups[serie_name].map((p) ->
          return [x_key_parser(p[x_key]),  + p.mpe]
        )

        lower_point_mpe = series_groups[serie_name].map((p) ->
          return [x_key_parser(p[x_key]), - p.mpe]
        )

        series.push
          name: serie_name + ' MPE'
          type: 'line'
          color: "#FF1000"
          dashStyle: "ShortDash"
          marker: symbol: "diamond"
          data: upper_point_mpe
          tooltip:
            headerFormat: ''
            pointFormatter: () ->
              return ''

        series.push
          linkedTo:':previous'
          type: 'line'
          color: "#FF1000"
          dashStyle: "ShortDash"
          marker: symbol: "diamond"
          data: lower_point_mpe
          tooltip:
            headerFormat: ''
            pointFormatter: () ->
              return ''
      )
      return series

    # Get model influence vars names
    model_influence_vars = () ->
      influence_vars = _.filter(spreadsheetEditor.getEditor('root.model.variables').getValue(), (x) ->
        x.influence
      ).map (v) ->
        v.name
      return influence_vars


    # function to get array item closest to specified key
    #http://stackoverflow.com/questions/4811536/find-the-number-in-an-array-that-is-closest-to-a-given-number
    getClosest = (array, key, target) ->
      tuples = _.map(array, (val) ->
        [
          val
          Math.abs(val[key] - target)
        ]
      )
      _.reduce(tuples, ((memo, val) ->
        if memo[1][key] < val[1][key] then memo else val
      ), [
        -1
        999
      ])[0]

    ################################################################################
    # Function to populate unc table
    ################################################################################

    build_unc_table = (_results, _range_id, _uut_id) ->
      if _results.U isnt undefined
        unc_table.fnClearTable()

        data = []

        max_contribution = Math.max.apply(0,_results.ci_ui)

        for u, i in _results.uncertainties
          # Skip null contributions
          if (_results.ci_ui[i] isnt null) and (parseFloat(u.value) isnt 0)
            bar_size = (+_results.ci_ui[i]/max_contribution) * 100
            color = percentToRGB(bar_size*0.9)
            var_name = _results.uncertainties_var_names[i]
            data.push([
              var_name
              _results.units[var_name]
              u.name
              u.type
              (+u.value).toExponential(3)
              u.distribution
              (+_results.ui[i]).toExponential(3)
              (+_results.ci[i]).toExponential(3)
              (+_results.ci_ui[i]).toExponential(3)
              "<svg width='100px' height='7px'><rect width='" + bar_size.toString() + "px' height='7px' style='fill:" + color + ";stroke-width:0;stroke:rgb(0,0,0)' /></svg>"
            ])
        # Populate editor with contribution sorted data
        unc_table.fnAddData(_.sortBy(data, (a) -> return -parseFloat(a[7]) ))

        # Trend chart
        if (_range_id isnt undefined) and (_uut_id isnt undefined)
          $.get "/spreadsheets/get_tendency?_range_id=" + _range_id + "&_uut_id=" + _uut_id, (data) ->
           
            # flat and grouped by calibration date
            grouped_data = _.groupBy data.map((x) ->
              obj = x._results
              obj.calibration_date = x.calibration_date
              if obj.calibration_date is null
                console.warn "Calibration_date is null. Trend chart will not be shown properly."
              obj.serie_name = "Serie"
              return obj
            ), "calibration_date"

            choosen_data = []
            _.keys(grouped_data).map((k) ->
              group = grouped_data[k]
              # First, find by influence quantities
              influence_vars = model_influence_vars()
              if influence_vars.length
                influence_match_obj = (_.pick(_results.scope, influence_vars))
                group_where_equals_influence = _.where(grouped_data[k], influence_match_obj)
                if group_where_equals_influence.length
                  group = group_where_equals_influence
                  # find closest item
                  closest = _.sortBy(group, (x) ->
                    Math.abs(_results.uut_readout - x.uut_readout)
                  )[0]
                  choosen_data.push(closest)
              else
                # Find where scope have exact same keys
                group_with_same_keys = _.filter(group, (g) ->
                  arr1 = _.keys(_results.scope)
                  arr2 = _.keys(g.scope)
                  # Compare if arrays have same keys
                  # http://stackoverflow.com/questions/1773069/using-jquery-to-compare-two-arrays-of-javascript-objects
                  return $(arr1).not(arr2).length is 0 and $(arr2).not(arr1).length is 0
                )
                if group_with_same_keys.length
                  group = group_with_same_keys
                  # find closest item
                  closest = _.sortBy(group, (x) ->
                    Math.abs(_results.uut_readout - x.uut_readout)
                  )[0]
                  choosen_data.push(closest)
            )
            # Sort
            choosen_data = _.sortBy(choosen_data, (x) ->
              return Date.parse(x.calibration_date)
            )

            x_key_parser = (x) ->
              return Date.parse(x)
            
            series = set_chart_series(choosen_data, "calibration_date", x_key_parser)
            if choosen_data.length
              chart_unit = choosen_data[0].uut_unit
            else
              chart_unit = ""

            $('#trend_container').highcharts
              credits: enabled: false
              exporting: enabled: true
              chart:
                zoomType: 'xy'
              title: text: "Point trend"
              xAxis:
                type: 'datetime'  
                #dateTimeLabelFormats:
                #  day: '%e of %b'
                title: text: 'Date'
                minRange: 1e-12
              yAxis:
                title: text: if chart_unit is "" then "" else "error (" + chart_unit + ")"            
              plotOptions: spline: marker: enabled: true
              tooltip: shared: true
              series: series
      return

    ################################################################################
    # Save data
    ################################################################################

    window.auto_save = () ->
      # build tags based on wat was used on spreadsheet
      try
        uut_name = spreadsheetEditor.getEditor("root.model.variables.0.name").getValue()

        uut_name_list = window.hot.getSourceData().map( (r) ->
          return r[uut_name].snippet
        )

        uut_name_list_uniq = _.uniq(uut_name_list.filter( (x) -> return x isnt null) )
        
        # get tags from all uut detected on worksheet
        tags = _.select( spreadsheetEditor.getEditor("root.choosen_snippets").getValue(), (x) -> 
          uut_name_list_uniq.indexOf(x.label) isnt -1
        )
        .map (x) ->
          return x._tag_list
        
        assets_tags = _.uniq(tags.join().split(/[\s,]+/))

        math_tags = spreadsheetEditor.getEditor("root.model._tag_list").getValue().split(/[\s,]+/)

        intersection = (_.intersection(assets_tags, math_tags))

        $("#spreadsheet_tag_list").tagsinput('removeAll')
        $("#spreadsheet_tag_list").tagsinput('add', intersection.toString())

        # Define text on header to show user a description of what is about the spreadsheet
        title = uut_name_list_uniq.toString()
        $("#spreadsheet_data_description").text(uut_name_list_uniq.toString())
        $("#spreadsheet_data_description_tags").text(intersection.toString())
        window.document.title = title

        $("#spreadsheet_spreadsheet_json").val(JSON.stringify(hot.getSourceData()))

        $(".spreadsheet_feature").submit()
      catch e
        console.log "Cant save"
        console.log e


    ################################################################################
    # Callbacks for handsontable context menu items
    ################################################################################

    handsontableContextMenuCallbacks = (key, options) ->
      if key is "readouts"
        # Clean editor
        if window.readoutsEditor
          window.readoutsEditor.destroy()
          delete window.readoutsEditor
        schema_items = _.filter( window.spreadsheetEditor.getEditor("root.model.variables").getValue(), {influence: false} )
        schema = {}
        for v in schema_items
          schema[v.name] = null

        columns = schema_items.map (v) ->
          obj =
            data: v.name
            color: v.color
            renderer: colorRenderer
          return obj
      if key is "plot"
        plot_chart()
        $('#chart').modal('toggle')
      if key is "permalink"
        url = 'https://share.measbox.com/spreadsheets/'
        content = {}
        content.input = JSON.parse($("#spreadsheet_spreadsheet_json").val()).map((x) ->
          x._results = {}
          return x
        )
        content.data = JSON.parse $("#spreadsheet_table_json").val()
        encoded = LZString.compressToEncodedURIComponent( JSON.stringify content )
        
        url += '?data=' + encoded
        console.log url
        window.open(url, '_blank')
      if key is "run_automation"
        console.log "Automation task data:"
        task = {}
        task.selection = hot.getSelected()
        if task.selection is undefined then return
        task.input = hot.getSourceData()
        task.data = window.spreadsheetEditor.getValue()
        console.log task
        task_handler = new MBAuto("ws://127.0.0.1:9000", hot)
        task_handler.sendTask(task)
        
      if key is "save"
        # Save spreadsheet
        auto_save()
      if key is "calc"
        # Save spreadsheet
        auto_save()
      if key is "details"
        # Ret selected row
        console.log options
        curr_data = hot.getSourceData()[options.end.row]
        build_unc_table(curr_data._results, curr_data._range_id, curr_data._uut_id)
        $('#rowDetails').modal('toggle')
      if key is "mc"
        process_entries([hot.getSelected()], true)
      return

    snippets_autocomplet_source = (query, process) ->
      data = window.spreadsheetEditor.getEditor("root.choosen_snippets").getValue().map (s) ->
        s.label.trim()
      return if process isnt undefined then process data else data
      
    prefixes_autocomplet_source = (query, process) ->
      # The comented code seatch all assets and take the prefix string uniq itens
      ###
      editor_data = window.spreadsheetEditor.getValue()

      nested_prefix_list = editor_data.choosen_snippets.map (s) ->
        s.value.ranges.map (r) ->
          r.prefix.trim()
      data = _.uniq(_.flatten(nested_prefix_list))
      ###
      data = ["", "Y","Z","E","P","T","G","M","k","h","da","d","c","m","u","n","p","f","a","z","y"]
      return if process isnt undefined then process data else data
      
    all_autocomplete_source = (query, process) ->
      return process snippets_autocomplet_source().concat(prefixes_autocomplet_source())


    ################################################################################
    # Functions to update hot editors.
    # Colors, headers and schemas
    ################################################################################

    colorRenderer = (instance, td, row, col, prop, value, cellProperties) ->
      Handsontable.renderers.TextRenderer.apply this, arguments
      $(td).css background: columns[col]['color']
      $(td).css "font-style": columns[col]['font_style']
      
    colorDropdownRenderer = (instance, td, row, col, prop, value, cellProperties) ->
      Handsontable.renderers.AutocompleteRenderer.apply this, arguments
      $(td).css background: columns[col]['color']
      $(td).css "font-style": columns[col]['font_style']
      $(td).css "font-weight": "bold"
      #$(td).find("div").css "display: inline;"
      #$(td).append '<div class="htAutocompleteArrow">▼</div>'

    prefixCellRenderer = (instance, td, row, col, prop, value, cellProperties) ->
      Handsontable.renderers.TextRenderer.apply this, arguments
      $(td).css background: columns[col]['color']
      $(td).css "font-weight": "bolder"
      $(td).css "border-right": "#C1C1C1";
      $(td).css "border-right-style": "double";


    # original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    strip_tags = (input, allowed) ->
      tags = /<\/?([a-z][a-z0-9]*)\b[^>]*>/gi
      commentsAndPhpTags = /<!--[\s\S]*?-->|<\?(?:php)?[\s\S]*?\?>/gi
      # making sure the allowed arg is a string containing only tags in lowercase (<a><b><c>)
      allowed = (((allowed or '') + '').toLowerCase().match(/<[a-z][a-z0-9]*>/g) or []).join('')
      input.replace(commentsAndPhpTags, '').replace tags, ($0, $1) ->
        if allowed.indexOf('<' + $1.toLowerCase() + '>') > -1 then $0 else ''


    chartRenderer = (instance, td, row, col, prop, value, cellProperties) ->
      Handsontable.renderers.TextRenderer.apply this, arguments
      cellProperties.readOnly = true
      if window.hot isnt undefined
        try
          td.innerHTML = window.hot.getDataAtRowProp(row, "_results")._error_chart
          $(td).popover
            trigger: 'hover'
            placement: 'left'
            container: 'body'
            html: true
            content: () -> 
              return $(this).find(".data_info").html()
        catch e
          console.log e
        

    disabledRenderer = (instance, td, row, col, prop, value, cellProperties) ->
      Handsontable.renderers.TextRenderer.apply this, arguments
      cellProperties.readOnly = true
      $(td).css "font-weight": "bolder"
      $(td).css "background": "#EEE"

    mathjs_eval_res = (formula, scope, res_var) ->
      if formula is undefined then return 0
      if typeof formula is "number" then return formula
      eval_res = mathjs.eval(formula, scope)
      if typeof scope[res_var] is "number" then return scope[res_var]
      # check if formula has multiple lines,
      # if true get the last entry as the uncertanti
      if typeof eval_res is "object"
        len = eval_res.entries.length
        res = eval_res.entries[len-1]
      else
        res = eval_res
      return res


    ################################################################################
    # Function to generate default comparision bars for MPE and cal U
    ################################################################################

    default_inline_chart = (_results) ->
      # Refresh chart content
      point_val = _results.scope[_results.uut_name]
    
      correct_value = point_val - _results.y
      bottom_u = correct_value - _results.U 
      upper_u = correct_value + _results.U 
      
      bottom_mpe = point_val - _results.mpe
      upper_mpe = point_val + _results.mpe

      max_value = Math.max(upper_u, upper_mpe)
      offset = Math.min(bottom_u, bottom_mpe)
      u_y = 8
      mpe_y = 18

      ################################################################################
      # Chart elements
      # TODO sanatize this
      ################################################################################

      res = '<svg height="22px" width="300px">' + \
      '<circle cx="' + ((correct_value - offset) / (max_value - offset))*100 + '%" cy="' + u_y + '" r="3" fill="#00628C" stroke="none"></circle>' + \
      '<line x1="' + ((bottom_u - offset) / (max_value - offset))*100 + '%" y1="' + u_y + '" x2="' + ((upper_u - offset) / (max_value - offset))*100 + '%" y2="' + u_y + '" style="stroke:#00628C;stroke-width:1.5" />' + \
      '<circle cx="' + ((point_val - offset) / (max_value - offset))*100 + '%" cy="' + mpe_y + '" r="3" fill=rgb(170,0,0) stroke="none"></circle>' + \
      '<line x1="' + ((bottom_mpe - offset) / (max_value - offset))*100 + '%" y1="' + mpe_y + '" x2="' + ((upper_mpe - offset) / (max_value - offset))*100 + '%" y2="' + mpe_y + '" style="stroke:rgb(170,0,0);stroke-width:1.5;" />' + \
      '</div>' + \
      '</svg>'
      return res

    ################################################################################
    # GUM response postprocessing
    ################################################################################


    handle_gum_response = (calc, mc) ->
      that = this
      _results = 
        "U": calc.U
        "ci": calc.ci
        "df": calc.df
        "k": calc.k
        "uc": calc.uc
        "ui": calc.ui
        "ci_ui": calc.ci_ui
        "uncertainties": calc.uncertainties
        "uncertainties_var_names": calc.uncertainties_var_names
        "veff": calc.veff
        "y": calc.y
        "uut_name": this._uut_name
        "uut_readout": this.base_scope.uut_readout
        "correct_value": this.base_scope.uut_readout - calc.y
        "scope": that.base_scope
        "uut_unit": worksheet_snippet.value.unit
        "uut_prefix": window.hot.getDataAtRowProp(row_num, this._uut_name).prefix
        "mpe": this._mpe
        "units": this._units
        #"_uut_id": this._uut_id
        #"_range_id": this._range_id

      if this.unc_source_obj.mc is true
        $("#mcLoading").toggle()
        $('#mcPlot').modal('toggle')
        # Unit on tooltip
        tooltip_unit = if _results.uut_unit isnt '-' then _results.uut_unit else ''
        y_ax_unit = if _results.uut_unit isnt '-' then _results.uut_unit else 'unit'
        mc = calc.mc
        mc_chart = new (Highcharts.Chart)(
          credits: enabled: false
          title: text: "Probability density function"
          chart:
            renderTo: 'mc_container'
            type: 'column'
          xAxis: 
            title: text: y_ax_unit
            plotLines: [ {
              value: mc.sci_limits[0]
              color: 'blue'
              width: 2
              #label:
              #  text: 'MCM low: ' + mc.sci_limits[0].toExponential(3)
              #  style: color: 'black'
            }, {
              value: mc.sci_limits[1]
              color: 'blue'
              width: 2
              #label:
              #  text: 'MCM high: ' + mc.sci_limits[1].toExponential(3)
              #  style: color: 'black'
            }, {
              value: calc.y-calc.U
              color: '#FF1000'
              dashStyle: 'shortdash'
              width: 2
              #label:
              #  text: 'GUM low: ' + -calc.U.toExponential(3)
              #  style: color: 'black'
            }, {
              value: calc.y+calc.U
              color: '#FF1000'
              dashStyle: 'shortdash'
              width: 2
              #label:
              #  text: 'GUM high: ' + calc.U.toExponential(3)
              #  style: color: 'black'                
            } ]
            #categories: calc.mc.histogram.x
            labels: formatter: ->
              @value.toExponential(2)
          yAxis:
            title: text: "Probability density/(1/" + y_ax_unit + ")"
          series: [
            {
              name: 'MC'
              data: calc.mc.histogram.y 
              pointStart: calc.mc.histogram.x[0]
              pointInterval: calc.mc.histogram.x[1] - calc.mc.histogram.x[0]
              tooltip:
                headerFormat: '<b>{series.name}</b><br>'
                pointFormatter: () ->
                  return '<b>U:</b> ' + this.x.toExponential(2) + ' ' + tooltip_unit
            },{
              name: 'GUM'
              data: calc.mc.gum_curve
              color: '#FF1000'
              type: 'spline'
              pointStart: calc.mc.histogram.x[0]
              pointInterval: calc.mc.histogram.x[1] - calc.mc.histogram.x[0]
              tooltip:
                headerFormat: '<b>{series.name}</b><br>'
                pointFormatter: () ->
                  return '<b>U:</b> ' + this.x.toExponential(2) + ' ' + tooltip_unit
            }
          ]
          plotOptions: column:
            shadow:false
            borderWidth:.5
            borderColor:'blue'
            pointPadding:0
            groupPadding:0
            color: 'rgba(204,204,204,.65)'
        )
        _results.mc = _.omit(mc, ['_scope', '_iterations', '_iterations_mean', 'histogram', 'histogram_x', 'gum_curve']);
        gum_text = 
          '<table cellpadding="0" cellspacing="0" border="0" class="table table-bordered table-striped"><caption><b>RESULTS</b></caption>' + \
          '<tr><td>M</td><td> <b>' + mc.M + '</b></td></tr>' + \
          '<tr><td>y</td><td> <b>' + mc._iterations_mean.toExponential(2) + '</b></td></tr>' + \
          '<tr><td>u(y)</td><td> <b>' + mc.uc.toExponential(2) + '</b></td></tr>' + \
          '<tr><td>~' + Math.round((1 - mc.p)*100) + ' % coverage interval</td><td> <b>[' + mc.sci_limits[0].toExponential(2) + ', ' + mc.sci_limits[1].toExponential(2) + ']</b></td></tr>' + \
          '<tr><td>d<sub>low</sub></td><td> <b>' + mc.d_low.toExponential(2) + '</b></td></tr>' + \
          '<tr><td>d<sub>high</sub></td><td> <b>' + mc.d_high.toExponential(2) + '</b></td></tr>' + \
          '<tr><td>GUF validated (δ = ' + mc.num_tolerance + ')?</td><td> <b>' + mc.GUF_validated + '</b></td></tr>' + \
          '</table>'
        $("#gum_text").html(gum_text);
        

      # Copy var values to results
      _.extend(_results, calc._scope, that.base_scope)

      # Register resolutions on _results
      _resolution_keys = _.allKeys(this._resolutions)
      for key in _resolution_keys
        _results[key] = this._resolutions[key]

      # If only two varibles exists, its a direct comparison measurement
      # so in this case we use the secont variable as the reference and register to _results
      # the resolution of it
      measurand_variables = _.filter( variables_editor.getValue(), {influence: false} )
      if measurand_variables.length is 2
        _results["reference_resolution"] = this._resolutions[_resolution_keys[1]]
      else
        _results["reference_resolution"] = 0
      
      ################################################################################
      # Eval post porocessing
      ################################################################################

      mathjs.eval(model_data.additional_options.post_processing, _results)
      # Output
      console.log "Output"
      console.log _results
      
      # parse results prevew 
      _results._preview_content = swig.render(model_data.additional_options.results_preview, locals: _results)
      _results._preview_content = kramed.parse(_results._preview_content)

      
      # User can use default unc bars chart on results preview, or custom code
      if model_data.additional_options.inline_graph
        custom_template = model_data.additional_options.custom_inline_graph
        if custom_template is undefined
          _results._error_chart = default_inline_chart(_results)
        else
          _results._error_chart = swig.render(custom_template, locals: _results)
        # ALwais add mouse over content
        _results._error_chart += '<div class="data_info" style="display: none;">' + _results._preview_content

      
      window.hot.undoRedo.ignoreNewActions = true
      window.hot.setDataAtRowProp(row_num, "_results", _results, "set_results")

      # Parameter used to query results history
      window.hot.setDataAtRowProp(row_num, "_uut_id", this._uut_id, "set_results")
      window.hot.setDataAtRowProp(row_num, "_range_id", this._range_id, "set_results")
      # Trigger on change on json-editor
      window.hot.undoRedo.ignoreNewActions = false
      spreadsheetEditor.onChange()

    process_entries = (changes, mc) ->
      that = this
      ################################################################################
      # When changes exists and its not seting results
      ################################################################################
      for change in changes
        this.row_num = change[0]
        # variables editor
        this.variables_editor = spreadsheetEditor.getEditor("root.model.variables")
        # uut is the first variable
        this._uut_name = this.variables_editor.getValue()[0].name              
        # UUT value without prefix
        this._uut_val_wo_prefix = NaN
        # object to build and send to uncertanty calc framework
        # set it initialy with variables and influence_quantities
        this.unc_source_obj = 
          variables: []
          influence_quantities: []

        ################################################################################
        # filter model variables object
        ################################################################################

        this.variables_editor.getValue().map (v, i) ->
          variable = Object.create(v)
          variable.name = v.name
          delete variable.color
          is_influence = variable.influence
          if is_influence
            if window.hot.getDataAtRowProp(that.row_num, variable.name) isnt undefined
              variable.value = window.hot.getDataAtRowProp(that.row_num, variable.name).readout
              variable.prefix = window.hot.getDataAtRowProp(that.row_num, variable.name).prefix
            that.unc_source_obj.influence_quantities.push variable
          else
            value = window.reject_non_numbers(window.hot.getDataAtRowProp(that.row_num, variable.name).readouts)
            # if first, is uut. Set variable
            if i is 0
              that._uut_val_wo_prefix = jStat.mean( value.map (r) -> return parseFloat(r) )
            variable.value = value
            variable.prefix = window.hot.getDataAtRowProp(that.row_num, variable.name).prefix
            that.unc_source_obj.variables.push variable
        

        # snippet editor
        this.snippets_editor = spreadsheetEditor.getEditor("root.choosen_snippets")
        
        ################################################################################
        # Create scope to use when parsing expression with math.js
        ################################################################################

        this.base_scope = {}
        this.base_scope.uut_readout = this._uut_val_wo_prefix * prefix_val(window.hot.getDataAtRowProp(this.row_num, this._uut_name).prefix)

        this.unc_source_obj.influence_quantities.map (iq) ->
          that.base_scope[iq.name] = parseFloat(iq.value)*prefix_val(iq.prefix)
        
        this.unc_source_obj.variables.map (v) ->
          # determine mean
          # default is 0
          that.base_scope[v.name] = 0
          # If on snippet, the var is set as readout, overwrite with the mean
          if v.readout
            mean_value = jStat.mean( v.value.map (r) -> return parseFloat(r) )
            that.base_scope[v.name] = mean_value * prefix_val(window.hot.getDataAtRowProp(this.row_num, v.name).prefix)

        # init max permissive error
        this._mpe = 0
        # Hold resolution for each variable
        this._resolutions = {}
        this._units = {}
        this.var_range_unc = {}
        this.var_range_scope = {}
        this.unc_source_obj.variables.map (v, var_index) ->
          # get snippet by label
          snippet = _.findWhere(that.snippets_editor.getValue(), {label: window.hot.getDataAtRowProp(that.row_num, v.name).snippet} )
          # didnt found any snippet, stop here
          if snippet is undefined then return
          # save the uuid of the snippet,
          # the first index is the UUT
          if var_index is 0 then that._uut_id = snippet.asset_id
          # Copy scope by val
          #scope = Object.create(that.base_scope)
          scope = JSON.parse JSON.stringify that.base_scope
          scope.readout = that.base_scope[v.name]
          scope.is_fixed = if snippet.value.kind is "Fixed" then true else false
          scope.is_uut = (v.name is that._uut_name)
          for r in snippet.value.ranges
            that._units[v.name] = snippet.value.unit
            # Add some keys to scope
            scope.range_start = r.limits.start
            scope.range_end = r.limits.end
            scope.fullscale = r.limits.fullscale
            # Set nominal value, based only on the asset, not reclassification
            mathjs.eval(r.nominal_value, scope)
            # Define resolution
            resolution = mathjs.eval(r.limits.resolution, scope)
            scope.resolution = resolution
            that._resolutions[v.name+"_resolution"] = resolution
            # is is uut, create alias
            if scope.is_uut
              that._resolutions["uut_resolution"] = resolution
              # add unique range identifier
              that._range_id = r._identifier

            ################################################################################
            # Test if this is a suitable range
            ################################################################################

            truth_test = mathjs.eval(r.limits.autorange_conditions, scope)
            if truth_test
              # Check for reclassifications
              if r.reclassification isnt undefined
                uncertainties = r.reclassification
              else
                uncertainties = r.uncertainties
              # Range found, break loop
              break
          # Set fixed values and corrections
          total_correction = 0
          that.var_range_unc[v.name] = uncertainties
          uncertainties.map (range_u) ->
            c_res = mathjs_eval_res(range_u.correction, scope, "c")
            total_correction = total_correction + c_res
          # If is fixed, need to set the readout value to GUM variable entry
          corr_value = scope.readout + total_correction
          if scope.is_fixed
            that.unc_source_obj.variables[var_index].value = corr_value
          that.base_scope[v.name] = corr_value
          that.var_range_scope[v.name] = scope

        # Now with a updated scope, set uncertanties
        this.unc_source_obj.variables.map (v, var_index) ->
          # Set scope
          scope = $.extend({}, that.var_range_scope[v.name], that.base_scope)
          scope.readout = scope[v.name]
          
          # If did not found range
          if that.var_range_unc[v.name] is undefined then return

          u_list = that.var_range_unc[v.name].map (range_u) ->
            # Get possible max permissive error increment
            if (range_u.name is "MPE") and scope.is_uut
              u_res = mathjs_eval_res(range_u.formula, scope)
              that._mpe += u_res
              # When unc is MPE and variable is UUT, dont add uncertanty to budget
              u_res = 0
            else
              u_res = mathjs_eval_res(range_u.formula, scope)
            u_obj = 
              name: range_u.name
              value: u_res
              distribution: range_u.distribution

            if range_u.k isnt undefined then u_obj.k = range_u.k
            if range_u.df isnt undefined then u_obj.df = range_u.df
            if range_u.ci isnt undefined then u_obj.ci = range_u.ci
            if range_u.custom_pdf isnt undefined then u_obj.custom_pdf = range_u.custom_pdf
            return u_obj
          # add uncertainties
          that.unc_source_obj.variables[var_index].uncertainties = u_list

        # Get snippet object
        this.worksheet_snippet = _.findWhere(this.snippets_editor.getValue(), {label: window.hot.getDataAtRowProp(this.row_num, this._uut_name).snippet})
        # Set label text
        #uut_val_label = this._uut_val_wo_prefix.toString() + " " + window.hot.getDataAtRowProp(this.row_num, this._uut_name).prefix + this.worksheet_snippet.value.unit + this._uut_range_label

        ################################################################################
        # Call GUM
        ################################################################################

        this.model_data = spreadsheetEditor.getEditor("root.model").getValue()
        this.unc_source_obj.func = this.model_data.func
        this.unc_source_obj.cl = this.model_data.additional_options.cl


        # Check for monte carlo
        if mc is true
          this.unc_source_obj.mc = true
        else
          this.unc_source_obj.mc = false
        try
          if this.unc_source_obj.mc is true
            $("#mcLoading").toggle()

          # Entry data
          console.log "Entry data"
          console.log unc_source_obj
          
          calc = new GUM(unc_source_obj)
          handle_gum_response(calc)
        catch e
          console.log e
          spreadsheetEditor.onChange()

      return # THIS RETURN HERE IS IMPORTANT! (probems with undo)

    ################################################################################
    # Control color to instruments colum
    ################################################################################

    increase_brightness = (color, percent) ->
      f = parseInt(color.slice(1), 16)
      t = if percent < 0 then 0 else 255
      p = if percent < 0 then percent * -1 else percent
      R = f >> 16
      G = f >> 8 & 0x00FF
      B = f & 0x0000FF
      '#' + (0x1000000 + (Math.round((t - R) * p) + R) * 0x10000 + (Math.round((t - G) * p) + G) * 0x100 + Math.round((t - B) * p) + B).toString(16).slice(1)


    ################################################################################
    # Generate deffinition hot settings
    ################################################################################

    window.entries_hot_settings = (data) ->
      that = this
      this.data = data
      @dataSchema = {}
      @columns = []
      #@colWidths = []
      @col_headers = []
      data.variables.map((v) ->
        that.dataSchema[v.name] = {}
        # Readouts
        bright_color = increase_brightness(v.color, 0.3)
        if v.influence
          col_name = v.name
          # Feed schema columns color and type
          that.col_headers.push col_name
          that.dataSchema[v.name]["readout"] = null
          that.columns.push
            data: v.name+".readout"
            color: bright_color
            renderer: colorRenderer
        else
          # Snippet col
          that.dataSchema[v.name]["snippet"] = null
          that.col_headers.push "<b><i class='fa fa-caret-right'></i> "+v.name+'</b> <sub>instrument</sub>'
          that.columns.push
            width: 120
            data: v.name+".snippet"
            color: v.color
            renderer: colorDropdownRenderer
            type: 'dropdown'
            strict: true
            allowInvalid: false
            wordWrap: false
            source: snippets_autocomplet_source
          if v.readout
            that.dataSchema[v.name]["readouts"] = []
            for i in [1..that.data.n_read] by 1
              col_name = v.name + " <sub> " + i + "</sub>"
              # Feed schema columns color and type
              that.col_headers.push col_name
              that.dataSchema[v.name]["readouts"].push null
              that.columns.push
                width: data.additional_options.readout_field_width
                data: v.name+".readouts."+(i-1).toString()
                color: bright_color
                renderer: colorRenderer
        if v.readout
          # Prefix
          # Feed schema columns color and type
          that.col_headers.push "×"
          #that.col_headers.push " "
          that.dataSchema[v.name]["prefix"] = null
          that.columns.push
            width: 40
            data: v.name+".prefix"
            color: bright_color
            renderer: prefixCellRenderer
            type: 'dropdown'
            strict: false
            allowInvalid: false
            source: prefixes_autocomplet_source
            className: "htCenter"
      )
      that.dataSchema["_results"] = {}
      
      # Error bar chart
      if data.additional_options.inline_graph
        that.col_headers.push "Results"
        that.dataSchema["_chart"] = null
        that.columns.push
          width: 310
          data: "_chart"
          renderer: chartRenderer

      settings = 
        data: []
        colHeaders: col_headers
        startCols: col_headers.length
        dataSchema: dataSchema
        columns: columns
        minSpareRows: 1

        ################################################################################
        # After change hot function callback
        ################################################################################

        afterChange: (changes, source) ->
          if (changes is null) or (source is "set_results") or (source is "snippet_change")# or (source is "undo") or (source is "redo")
            return
          try
            console.log "Processing changes..."
            clearTimeout window.afterChangeTimeoutID
            window.afterChangeTimeoutID = setTimeout (->
              console.log "Changes:"
              process_entries(changes)
            ), 1500
          catch e
            console.log e
          return


        ################################################################################
        # Continue to other hot configs
        ################################################################################

        #manualColumnResize: true
        contextMenu: true
        contextMenu:
          callback: handsontableContextMenuCallbacks
          items:
            row_above:
              disabled: ->
                #if first row, disable this option
                this.getSelected()[0] is 0
            row_below: {}
            hsep1: "---------"
            remove_row: {}
            hsep2: "---------"
            plot:
              name: "Chart"
            details:
              name: "Details"
            mc:
              name: "Monte Carlo"
            permalink:
              name: "Permalink"
            run_automation:
              name: "Automation task"
            save:
              name: "Save"
      return settings

    ################################################################################
    # Update handsontable range select text when the label is changed on choosen snippets data
    ################################################################################
    
    replace_autocomplete_text = (changes, row) ->
      that = this
      this.props_to_verify = _.filter( window.spreadsheetEditor.getEditor("root.model.variables").getValue(), {influence: false} )
      changes.map (c) ->
        # Get current labels on handsontable
        that.props_to_verify.map (p) ->
          if window.hot.getDataAtRowProp(row, p.name+".snippet") is c.old
            window.hot.setDataAtRowProp(row, p.name+".snippet", c.new, "snippet_change")
            window.hot.render()

    ################################################################################
    # Filter change ocorrences on choosen_snippets editor and call functions to change
    ################################################################################

    treat_snippet_changes = (changes) ->
      that = this
      # Iterate over hot objects
      hot.getSourceData().map (_, row) ->
        replace_autocomplete_text(changes, row)

    ################################################################################
    # Observe snippets and model for changes
    ################################################################################

    window.SnippetsObserver = () ->
      that = this
      this.editor = window.spreadsheetEditor.getEditor('root.choosen_snippets')
      this.prev_labels = []
      this.curr_labels = []
      this.get_labels = () ->
        that.editor.getValue().map (s) ->
          s.label
      this.init = () ->
        that.curr_labels = that.prev_labels = that.get_labels()
        # Snippets
        window.spreadsheetEditor.watch 'root.choosen_snippets', () ->
          that.prev_labels = that.curr_labels
          that.curr_labels = that.get_labels()
          # check difference to detect sort,
          # when data was sorted, no action is triggered
          diff = _.difference(that.prev_labels, that.curr_labels)
          changes = []
          if diff.length isnt 0
            changes = diff.map (old_val) ->
              index_value_changed = _.indexOf(that.prev_labels, old_val)
              new_val = that.curr_labels[index_value_changed]
              return {"old": old_val, "new": new_val}
          treat_snippet_changes(changes)

        # Model
        window.spreadsheetEditor.watch 'root.model', () ->
          update_hot_settings()

      this.init()

    ################################################################################
    # Build editor
    ################################################################################
    window.auto_save_handler = undefined
    window.spreadsheetEditorBuilder = (data) ->
      # Dont polute db with the text procedure
      delete data.procedure
      delete window.mathFormSchema.properties.procedure

      if window.spreadsheetEditor is undefined
        window.spreadsheetEditor = create_json_editor("#spreadsheet_table_json", window.spreadsheetEntriesSchema)
        window.spreadsheetEditor.on "ready", () ->

          if not standaloneMode
            ################################################################################
            # Refresh choosen snippets TODO: Clean this, maybe using other aproach, like other json-editor
            ################################################################################

            # add refresh button
            #$(".container-choosen_snippets").find(".json-editor-btn-delete")
            $("[data-schemapath='root.choosen_snippets'").find(".json-editor-btn-delete")
            .first()
            .after('<button type="button" class="btn btn-default" id="refresh_asset_snippets"><span class="glyphicon glyphicon-refresh"></span> Asset snippets</button>')

            $("#refresh_asset_snippets").click (e) ->
              e.preventDefault()
              snippetsEditor = window.spreadsheetEditor.getEditor("root.choosen_snippets")
              snippets = snippetsEditor.getValue()
              for snippet in snippets
                # When page is load, a hidden element is created holding the
                # asset_id, model_id and snippet_id of assets_snippets choosen at SERVICE.
                # This function update the asset snippet case user choose other asset.
                # It uses the position identifier to select the new choosen asset for the correponding asset_snippet
                $.get "../../snippets/get_json?id=" + snippet.snippet_id + "&asset_id=" + snippet.asset_id + "&model_id=" + snippet.model_id, (data) ->
                  data = filter_snippet_data(data)
                  index = _.findIndex( snippets, {asset_id: data.snippet.asset_id, snippet_id: data.snippet.snippet_id} )
                  data.snippet.position = snippets[index].position
                  # Update the editor data
                  ranges_editor = window.spreadsheetEditor.getEditor( "root.choosen_snippets."+index.toString()+".value.ranges")
                  # I dont know exactly why, but first seting the node null and than seting the data works, 
                  # but if I set it directly when I call .getValue() i cant get the updated data
                  #ranges_editor.setValue(null)
                  # *UPDATE: I think its solved now, dont need to set null anymore
                  ranges_editor.setValue(data.snippet.value.ranges)
                  window.spreadsheetEditor.getEditor( "root.choosen_snippets."+index.toString()+".automation").setValue(data.snippet.automation)
                  

            ################################################################################
            # Refresh math model
            ################################################################################

            # add refresh button
            #$(".container-model").find(".json-editor-btn-edit")
            $("[data-schemapath='root.model'").find(".json-editor-btn-edit")
            .first()
            .after('<button type="button" class="btn btn-default" id="refresh_math_snippet"><span class="glyphicon glyphicon-refresh"></span> Math snippets</button>')

            $("#refresh_math_snippet").click (e) ->
              e.preventDefault()
              if confirm "Do you want to update this spreadsheet to the latest version?"
                setTimeout (->
                  $.get "../../snippets/get_json?id=" + window.spreadsheetEditor.getValue().model._id, (data) ->
                    # update tags
                    data.snippet.value._tag_list = data.tag_list
                    model_editor = window.spreadsheetEditor.getEditor('root.model')
                    model_editor_value = model_editor.getValue()
                    # Dont allow _id to be overwrite
                    delete data.snippet.value._id
                    # Clear data
                    delete data.snippet.value.procedure
                    new_model_editor_value = $.extend({}, model_editor_value, data.snippet.value)
                    model_editor.setValue(new_model_editor_value)
                    update_hot_settings(new_model_editor_value)
                ), 100

            

          editor = window.spreadsheetEditor.getEditor("root.model")
          if (editor is null) or (editor is undefined)
            # If its first time creating the editor, we need to set data before
            # and reference to root intead of root.model
            editor = window.spreadsheetEditor.getEditor("root")
            value = 
              model: data
              choosen_snippets: []
              #worksheets: []
          else
            value = data
          editor.setValue(value)
          window.SnippetsObserver()

          ################################################################################
          # Handsontable
          ################################################################################    
          settings = window.entries_hot_settings(data)
          #console.log settings
          window.hot = new Handsontable( $("#hot_container")[0], settings )

          #window.hot.loadData(window.spreadsheetEditor.getEditor("root.worksheet").getValue())
          window.hot.loadData(JSON.parse($("#spreadsheet_spreadsheet_json").val()))

          # If its on standalone mode
          if standaloneMode
            changes = []
            hot.getSourceData().map (x, i) ->
              changes.push [
                i
                null
                null
                null
              ]
              return
            # Process all data
            try
              process_entries(changes)
            catch e
              console.log e
          window.hot.render()
          $("#hot_container").fadeIn()  
        ################################################################################
        # Auto save
        ################################################################################
        
        window.spreadsheetEditor.on "change", () ->
          clearTimeout window.auto_save_handler
          
          window.auto_save_handler = setTimeout((->
            auto_save()
            return
          ), 1000)


    ################################################################################
    # Filter data to fit choosen snippets schema
    ################################################################################

    window.filter_snippet_data = (data) ->
      data.snippet.label = data.model.name + " " + data.snippet.value.unit + " " + data.snippet.value.kind + " - " + data.asset.identification
      data.snippet.label = data.model.name
      if data.snippet.value.unit isnt "" then data.snippet.label += " (" + data.snippet.value.unit + ")"

      data.snippet.asset_id = data.asset.id
      data.snippet.snippet_id = data.snippet.id
      data.snippet.model_id = data.model.id

      # Set tags
      data.snippet._tag_list = data.tag_list
      
      data.snippet.automation = {}
      data.snippet.automation.visa_address = data.asset.visa_address
      code = data.model.code.automation
      code = code + ("\n\n" + data.snippet.value.automation.code).replace(/\n/g, "\n\t")

      data.snippet.automation.code = code

      # Manage reclassifications
      if data.asset.use_reclassification
        # Reject disabled reclassifications
        enabled_reclassification_ranges = _.reject data.asset.reclassification, (x) ->
          x.enabled is false

        # Remove enabled/disabled properties, so they dont appears on choosen snippets
        enabled_reclass_ranges_omit = enabled_reclassification_ranges.map (x) ->
          return _.omit(x, 'enabled')
        # Add reclassification to range, where it exists
        enabled_reclass_ranges_omit.map (r) ->
          index = _.findIndex(data.snippet.value.ranges, (x) ->
            return x._identifier.toString() is r._identifier.toString()
          )
          # If range found, add reclassificaions key to proper location
          if index > -1
            data.snippet.value.ranges[index].reclassification = r.uncertainties

      # Filter some stuff
      
      delete data.snippet.value.automation
      delete data.model
      delete data.asset
      delete data.snippet.id
      delete data.tag_list
      delete data.snippet.validated
      delete data.snippet.created_at
      delete data.snippet.flavor
      delete data.snippet.laboratory_id
      delete data.snippet.updated_at
      return data

    ################################################################################
    # Create user interface to choose snippets, when click on the search icon next to tags
    ################################################################################

    # actiion to search icon for the assets
    $(".search_fields").click (e) ->
      # Set a attribute on clicked element
      # But first, clear all
      $("span.search_fields[active='true']").each ->
        $(this).attr("active", false)
      $(this).attr("active", true)
      # Reach tag list
      asset_tags = $(this).parent().prev().val().split(/[\s,]+/) # This will trim the tags
      math_tags = spreadsheetEditor.getEditor("root.model._tag_list").getValue().split(/[\s,]+/)
      tag_list = _.uniq(_.sortBy(math_tags.concat(asset_tags))).join()
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


    ################################################################################
    # Update handsontable settings
    ################################################################################

    window.update_hot_settings = ->
      if window.hot_settings_update_handler isnt undefined
        clearTimeout window.hot_settings_update_handler

      window.hot_settings_update_handler = setTimeout (->
        editor_data = window.spreadsheetEditor.getEditor('root.model').getValue()
        new_settings = window.entries_hot_settings(editor_data)
        #old_settings = window.hot.getSettings()
        #new_settings = $.extend(true, 
        #  old_settings,
        #  settings
        #)
        
        delete new_settings.afterChange
        window.hot.updateSettings new_settings
        #window.hot.loadData(window.spreadsheetEditor.getEditor("root.worksheet").getValue())
        window.hot.loadData(JSON.parse($("#spreadsheet_spreadsheet_json").val()))
        window.hot.render()
      ), 1000


    ################################################################################
    # Chart function
    ################################################################################

    window.plot_chart = () ->
      influence_vars = model_influence_vars()

      # Get results, and set serie name
      data = hot.getSourceData().map((x) ->
        obj = x._results
        serie_keys = []
        influence_vars.map((v) ->
          if x[v] isnt undefined
            if (x[v].readout isnt null) and (x[v].readout isnt undefined)
              if (x[v].prefix is undefined) or (x[v].prefix is null)
                prefix = ''
              else
                prefix = x[v].prefix
              serie_keys.push(v + ': ' + if x[v].readout is undefined then '' else x[v].readout.toString() + if prefix is undefined then '' else ' ' + prefix.toString())
        )
        obj.serie_name = serie_keys.toString()
        return obj
      )

      # Reject data without readout
      data = _.reject(data,  (x) ->
        return x.uut_readout is undefined
      )

      # Sort
      data = _.sortBy(data, (x) ->
        return x.uut_readout
      )

      x_key_parser = (x) ->
        return x

      series = set_chart_series(data, "uut_readout", x_key_parser)


      chart_unit = get_chart_unit(data).trim()

      $('#chart_container').highcharts
        credits: enabled: false
        exporting: enabled: true
        chart:
          type: 'spline'
          zoomType: 'xy'
        title: text: $("#spreadsheet_tag_list").val()
        xAxis:
          type: 'number'
          title: text: 'Point'
          minRange: 1e-12
        yAxis:
          title: text: if chart_unit is "" then "" else "error (" + chart_unit + ")"
        plotOptions: spline: marker: enabled: true
        tooltip: shared: true
        series: series
