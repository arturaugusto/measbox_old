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
    
    editor = new MediumEditor('#report_value_html')
    $(".getdata").click (e) ->
      e.preventDefault()
      css = ''
      # Get all style tag content
      Array::map.call document.getElementsByTagName('style'), (s) ->
        data = s.firstChild.data
        css += '<style type="text/css">' + data + '</style>'
      
      # Split string containing styles
      # reject lines that contain fonts an than join again
      css = _.reject(css.split("\n"), (r) ->
        return /@font-face/.test(r)
      ).join("\n")
      
      html = editor.elements[0].innerHTML
      $("#report_value_html").val(css + html)
      $(".report_feature").submit()

    parse_and_transport = () ->
      content = $("#report_value").val()
      html = kramed.parse(content)
      $("#report_value_html").val(html)
      editor.destroy()
      editor.setup()
      setTimeout (->
        window.MathJax.Hub.Queue new (window.Array)('Typeset', window.MathJax.Hub)
      ), 400


    this_url = () ->
      return (document.URL).replace('/edit', '').replace('#', '')

    $(".getpdf").click (e) ->
      e.preventDefault()
      window.open(this_url() + ".pdf", "_blank")

    $(".printview").click (e) ->
      e.preventDefault()
      window.open(this_url()+"", "_blank")

    $(".markdownedit").click (e) ->
      e.preventDefault()
      $( ".markdown_textarea" ).toggle()


    # markdown textarea editor
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


    generate_report = (el) ->
      data = {}
      $.getJSON("../../report_templates/" + $("#report_report_template_id").val() + ".json").done (json) ->
        console.log json
        template = json.value
        pdf_options = json.pdf_options

        # Remove characteres that crashes the template engine
        #template = template.replace /{%.*?%}|{{.*?}}/g, (x) ->
        #  return x.replace /&nbsp;/g, " "
        #template = template.replace(/&lt;br&gt;/, "<br/>")


        $.getJSON("../../services/" + $("#report_service_id_ref").val() + ".json").done (data) ->
          traverseSwigApply(undefined, pdf_options, data.service.information)
          if typeof pdf_options is "object"
            $("#report_pdf_options").val(JSON.stringify(pdf_options))

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

          #console.log data
          content = swig.render(template,"locals": data)
          $("#report_value").val(content)
          parse_and_transport()

          return
        return

    $('.generate').click (e) ->
      generate_report()
      e.preventDefault()