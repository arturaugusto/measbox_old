# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $(".report_editor_feature").each ->

    # http://stackoverflow.com/questions/722668/traverse-all-the-nodes-of-a-json-object-tree-with-javascript
    traverseSwigApply = (parent, jsonObj, locals) ->
      $.each jsonObj, (k, v) ->
        if typeof v == 'object'
          traverseSwigApply k, v, locals
        if typeof v == 'string'
          jsonObj[k] = swig.render(jsonObj[k], 'locals': locals)
        return
      return

    set_iframe_editor_content = () ->
      html = $('#report_value_html').val()
      frame_el = $("#editor_frame")[0]
      if frame_el isnt undefined
        iframe_editor = frame_el.contentWindow.editor
        #iframe_editor.destroy()
        iframe_editor.setup()
        iframe_editor.setContent('<style type="text/css" scoped>' + $("#lab_style").text() + '</style>\n\n' + html)
    
    parse_and_transport = () ->
      md_content = $("#report_value").val()
      html = kramed.parse(md_content)
      # Update editor html
      $("#report_value_html").val(html)
      # Will render html to be processed by MathJax
      editor = new MediumEditor('#report_value_html')
      #editor.destroy()
      editor.setup()
      setTimeout (->
        window.MathJax.Hub.Queue new (window.Array)('Typeset', window.MathJax.Hub)
        setTimeout (->
          html = editor.elements[0].innerHTML
          $("#report_value_html").val(html)
          # IFrame
          set_iframe_editor_content()
        ), 400
      ), 400

    # Show report on init
    setTimeout (->
      set_iframe_editor_content()
    ), 1000


    # markdown textarea editor
    ###
    $(".markdownedit").click (e) ->
      e.preventDefault()
      $( ".markdown_textarea" ).toggle()
    $('.markdown_textarea').bind 'input keyup', ->
      $this = $(this)
      delay = 1000
      clearTimeout $this.data('timer')
      $this.data 'timer', setTimeout((->
        $this.removeData 'timer'
        parse_and_transport()
        return
      ), delay)
      return
    ###



    reshape_certificate_data = (data) ->
      # Unpack spreadsheets
      spreadsheets = data.spreadsheets.map((s) ->
        s.spreadsheet_json
      )
      # Flat all rows
      all_rows = _.flatten(spreadsheets)


      # List of uut ids
      uut_ids = _.filter _.uniq(all_rows.map((r) ->
        r._uut_id
      )), (x) ->
        x != undefined

      # list of uut assets
      ref_assets = _.filter(data.assets, (x) ->
        uut_ids.indexOf x.id
      )

      # List reference assets
      uut_assets = _.filter(data.assets, (x) ->
        !uut_ids.indexOf x.id
      )

      data.uut_assets = uut_assets
      data.ref_assets = ref_assets
      
      data.now = new Date()
      
      

      # Unpack choosen snippets
      choosen_snippets_flat =  _.flatten data.spreadsheets.map((s) ->
        s.table_json.choosen_snippets
      )

      # Unpack ranges from snippets
      ranges_flat = _.flatten choosen_snippets_flat.map((s) ->
        return s.value.ranges
      )

      range_snippet_map = {}
      choosen_snippets_flat.map((s) ->
        s.value.ranges.map((r) ->
          range_snippet_map[r._identifier] = s.value
        )
      )
      

      # List of range ids
      range_ids = _.filter _.uniq(all_rows.map((r) ->
        r._range_id
      )), (r_id) ->
        r_id != undefined

      # Return array of arrays containing the results of each row
      res_set = range_ids.map (id) ->
        row = _.filter(all_rows, (r) ->
          r._range_id == id
        )

        # Find uut range used reference
        range = _.findWhere( ranges_flat, {'_identifier': id} )
        range.snippet_name = range_snippet_map[id].name
        range.unit = range_snippet_map[id].unit
        range.kind = range_snippet_map[id].kind
        
        # prefix information
        rows_count = row.length
        range.last_prefix = row[rows_count-1]._results.uut_prefix
        range.last_prefix_val = row[rows_count-1]._results.uut_prefix_val

        # MPE
        _mpe = _.find( range.uncertainties , {'name': 'MPE'} )
        #console.log _mpe
        if _mpe isnt undefined
          _mpe_formula_parsed = mathjs.parse(_mpe.formula)
          range.mpe_TeX = _mpe_formula_parsed.toTex()
          range.mpe_string = _mpe_formula_parsed.toString()
        else
          range.mpe_TeX = range.mpe_string = undefined
        # limits formated based on the last prefix used on range calibration
        range.start_fmt = (range.limits.start/range.last_prefix_val).toString()
        range.end_fmt = (range.limits.end/range.last_prefix_val).toString()
        range.fullscale_fmt = (range.limits.fullscale/range.last_prefix_val).toString()

        range.points = row.map (r, i) ->
          # Check warever current point changes the prefix relatively to previous point
          if i is 0
            prefix_transition = true
          else
            if row[i-1]._results.uut_prefix is r._results.uut_prefix
              prefix_transition = false
            else
              prefix_transition = false
          
          r._results.prefix_transition = prefix_transition
          return r._results
        return range

      data.cal_ranges = res_set
      console.log data
      return data

    generate_report = (el) ->
      data = {}
      $.getJSON("../../report_templates/" + $("#report_report_template_id").val() + ".json").done (json) ->
        template = json.value
        pdf_options = json.pdf_options

        $.getJSON("../../services/" + $("#report_service_id_ref").val() + ".json").done (data) ->

          traverseSwigApply(undefined, pdf_options, data.service.information)
          if typeof pdf_options is "object"
            $("#report_pdf_options").val(JSON.stringify(pdf_options))
          console.log pdf_options

          data = reshape_certificate_data(data)

          #console.log data
          content = swig.render(template,"locals": data)
          $("#report_value").val(content)
          # update div with new lab styles
          $("#lab_style").text(data.laboratory.custom_forms.styles)
          parse_and_transport()

          return
        return

    $('.generate').click (e) ->
      generate_report()
      e.preventDefault()

    # Click on save
    $(".getdata").click (e) ->
      e.preventDefault()
      iframe_editor = $("#editor_frame")[0].contentWindow.editor
      html = iframe_editor.elements[0].innerHTML
      $("#report_value_html").val(html)
      $(".report_feature").submit()      

    this_url = () ->
      return (document.URL).replace('/edit', '').replace('#', '')

    $(".getpdf").click (e) ->
      e.preventDefault()
      window.open(this_url() + ".pdf", "_blank")

    $(".printview").click (e) ->
      e.preventDefault()
      window.open(this_url()+"", "_blank")

