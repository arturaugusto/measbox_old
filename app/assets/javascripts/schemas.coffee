window.laboratoryCustomForms =
  options:
    collapsed: true
  title: "Enviroment"
  type: "object"
  properties: 
    services:
      type: 'code'
      format: 'matlab'
      title: 'Calibration Information layout'
      default: '''
{
  "type": "object",
  "title": "Calibration Information",
  "properties": {
    "certificates": {
      "type": "array",
      "options": {
        "collapsed": true
      },
      "title": "Certificates",
      "format": "table",
      "uniqueItems": true,
      "items": {
        "type": "object",
        "title": "Certificate",
        "properties": {
          "cert_number": {
            "title": "Number",
            "type": "string"
          },
          "description": {
            "title": "Description",
            "type": "string"
          }
        }
      }
    },
    "enviromental_conditions": {
      "type": "object",
      "title": "Enviromental",
      "properties": {
        "temperature": {
          "type": "string",
          "title": "Temperature"
        },
        "humidity": {
          "title": "Humidity",
          "type": "string"
        },
        "pressure": {
          "title": "Pressure",
          "type": "string"
        }
      },
      "options": {
        "collapsed": "undefined"
      }
    },
    "notes": {
      "type": "array",
      "options": {
        "collapsed": true
      },
      "title": "Notes",
      "uniqueItems": true,
      "items": {
        "type": "object",
        "title": "Note",
        "properties": {
          "note": {
            "title": "Note",
            "type": "string",
            "format": "textarea"
          }
        }
      }
    },
    "procedures": {
      "type": "array",
      "title": "Procedures",
      "uniqueItems": true,
      "items": {
        "type": "object",
        "title": "Procedure",
        "properties": {
          "procedure": {
            "title": "Procedure",
            "type": "string",
            "enum": [
              "aa",
              "bb"
            ]
          }
        }
      },
      "options": {
        "collapsed": true
      }
    }
  }
}
'''
    styles:
      type: 'code'
      format: 'css'
      title: 'Report styles'
      default: '''
.report_view p table div {
    font-family: "times";
    font-size: 14px;
}
.report_view table{
    min-width:50%;
    max-width:90%;
    font: inherit;
    text-align:left;
    margin:0;
}

.report_view td, tr, th{
    padding:2px 10px;
    margin:0;
    font-weight:normal;
}

.report_view th{
    border-bottom:1px solid #bbb;
}

.report_view table{
    margin:12px;
    padding-top: 25px;
    padding-right: 25px;
    padding-bottom: 25px;
    padding-left: 25px;    
}

'''    


window.pdfOptionsSchema =
  title: "PDF Options"
  type: "object"
  required: false
  options:
    collapsed: true
    disable_edit_json: true
  properties:
    orientation:
      type: "string"
      enum: [
        "Portrait"
        "Landscape"
      ]
    page_size:
      type: "string"
      enum: [
        "A4"
        "Letter"
      ]           
    margin:
      type: "object"
      options:
        collapsed: true
        disable_edit_json: true
      properties:
        top:
          type: "number"
          default: 10
        bottom:
          type: "number"
          default: 10
        left:
          type: "number"
          default: 10
        right:
          type: "number"
          default: 10
    header: 
      type: "object"
      options:
        collapsed: true
        disable_edit_json: true
      properties:
        left:
          type: "string"
        center:
          type: "string"
        right:
          type: "string"
          default: "Cert. n{{certificates[0].cert_number}}"
        spacing:
          type: "number"
        font_name:
          type: "string"
          default: "Helvetica"
        font_size:
          type: "number"
          default: "12"
    footer:
      type: "object"
      options:
        collapsed: true
        disable_edit_json: true
      properties:
        left:
          type: "string"
        center:
          type: "string"
          default: "[page]/[toPage]"
        right:
          type: "string"
        spacing:
          type: "number"
        font_name:
          type: "string"
          default: "Helvetica"
        font_size:
          type: "number"
          default: "12"

window.pageRoleSchemaProperties =
  index:
    type: "boolean"
  create:
    type: "boolean"
  edit:
    type: "boolean"
  update:
    type: "boolean"
  destroy:
    type: "boolean"
window.pageRoleSchema =
  type: "object"
  options:
    collapsed: true
    disable_edit_json: true
  properties: pageRoleSchemaProperties

window.validatablePageRoleSchema =
  type: "object"
  options:
    collapsed: true
    disable_edit_json: true
  properties:
    index:
      type: "boolean"
    create:
      type: "boolean"
    edit:
      type: "boolean"
    update_unvalidated:
      title: "update unvalidated"
      type: "boolean"
    update_validated:
      title: "update validated"
      type: "boolean"
    destroy_unvalidated:
      title: "destroy unvalidated"
      type: "boolean"
    destroy_validated:
      title: "destroy validated"
      type: "boolean"
window.rolesSchema =
  title: "Roles"
  type: "object"
  required: false
  options:
    disable_edit_json: true
  properties:
    services:
      validatablePageRoleSchema
    spreadsheets:
      type: "object"
      options:
        collapsed: true
        disable_edit_json: true
      properties:
        create:
          type: "boolean"
        edit:
          type: "boolean"         
    assets:
      pageRoleSchema
    models:
      pageRoleSchema
    manufacturers:
      pageRoleSchema
    kinds:
      type: "object"
      title: "type"
      options:
        collapsed: true
        disable_edit_json: true
      properties: pageRoleSchemaProperties
    snippets:
      validatablePageRoleSchema
    users:
      pageRoleSchema
    companies:
      pageRoleSchema
    laboratory:
      type: "object"
      options:
        collapsed: true
        disable_edit_json: true
      properties:
        edit:
          type: "boolean"
        update:
          type: "boolean"
    roles:
      pageRoleSchema
    system:
      type: "object"
      options:
        collapsed: true
        disable_edit_json: true
      properties:
        administrator:
          type: "boolean"
window.uncertaintiesSchema = uncertainties:
  type: "array"
  #format: "table"
  title: "Uncertainties"
  uniqueItems: true
  options:
    collapsed: true
  items:
    type: "object"
    headerTemplate: "{{self.name}}"
    options:
      collapsed: true
      disable_edit_json: true
      disable_properties: false
      remove_empty_properties: true
    properties:
      name:
        description: 'Uncertainties named "MPE" for the UUT will not be considered on final budget.'
        title: "Name"
        type: "string"

      description:
        title: "Description"
        type: "string"

      distribution:
        type: "string"
        title: "Distribution"
        enum: [
          "uniform"
          "normal"
          "triangular"
          "arcsine"
        ]
        default: "uniform"
      ###
      k:
        type: "number"
        title: "k"
        default: 2

      ci:
        type: "number"
        title: "ci"
        default: 0.95
      ###
      formula:
        title: "Formula"
        type: "string"
        format: "textarea"
        default: "u = 0.01 * readout"
        height: "100px"

  default: [
    {
      name: "Resolution"
      description: "Half of minimum step size"
      distribution: "Rect."
      formula: "u = resolution / 2"
    }
    {
      name: "MPE"
      description: "Maximum Permissible Error"
      distribution: "Rect."
      formula: "u = 0.005 * readout"
    }
  ]

window.mathFormSchema = 
  type: 'object'
  title: 'Model'
  options:
    disable_edit_json: false
    disable_properties: false
    disable_collapse: false
    collapsed: false
  properties:
    _id:
      type: "string"
      options:
        hidden: true
    _tag_list:
      type: "string"
      options:
        hidden: true
    variables:
      propertyOrder: 1
      title: 'Variables'
      description: 'The first item from this list will be treated as uut.'
      type: 'array'
      format: 'table'
      options: collapsed: true
      items:
        options:
          collapsed: true
          disable_edit_json: false
          disable_properties: false
          disable_collapse: false
        type: 'object'
        title: 'Variable'
        headerTemplate: '{{ self.name }}'
        properties:
          name:
            type: 'string'
            title: 'Name'
          color:
            type: 'string'
            format: 'color'
            title: 'Column color'
            default: '#ffffff'
          influence:
            type: 'boolean'
            title: 'Influence'
            default: false
          readout:
            type: 'boolean'
            title: 'Readout'
            default: true
      default: 
        [
          {
            "name": "VI",
            "color": "#ffffe7",
            "influence": false
          }
          {
            "name": "VC",
            "color": "#f2f1ff",
            "influence": false
          }
        ]

    n_read:
      propertyOrder: 2
      type: 'number'
      title: 'Repetitions'
      default: 4
    func:
      propertyOrder: 3
      type: 'code'
      format: 'matlab'
      title: 'Mathematical model'
      default: 'VI - VC'
      options:
        height: '40px'        
    additional_options:
      propertyOrder: 4
      type: 'object'
      title: 'Additional Options'
      options:
        disable_edit_json: true
        disable_properties: true
        disable_collapse: false
        collapsed: true
      properties:
        cl:
          type: 'number'
          title: 'Confidence level'
          default: 0.953
        automation:  
          type: "code"
          title: "Automation Script"
          format: "python"
          options:
            height: "100px"
        post_processing:
          type: 'code'
          format: 'python'
          title: 'Post Processing'
          default: 
            'k_fmt                = fmt_to_fixed(k, 2)\n' +
            'uut_prefix_val       = prefix_val(uut_prefix)\n' +
            'U_fmt                = fmt_to_precision(U / uut_prefix_val, 2)\n' +
            'U_prec               = decimal_places(U_fmt)\n' +
            'uut_readout_fmt      = fmt_to_fixed(uut_readout / uut_prefix_val, decimal_places(uut_resolution / uut_prefix_val) )\n' +
            'correct_value_fmt    = fmt_to_fixed(correct_value / uut_prefix_val, U_prec)\n' +
            'err_fmt              = fmt_to_fixed(y / uut_prefix_val, U_prec)\n' +
            'mpe_fmt              = fmt_to_fixed(mpe / uut_prefix_val, U_prec)\n' +
            'veff_fmt             = veff > 9999 ? "∞" : round(veff)'
          options:
            height: '100px'
        results_preview:
          type: 'string'
          format: 'textarea'
          title: 'Results Preview'
          default: 
            '<span style="color:#00628C">' +
            'Reference: {{correct_value_fmt}} {{uut_prefix}}{{uut_unit}}  \n' +
            'U: {{U_fmt}} {{uut_prefix}}{{uut_unit}}\n' +
            '</span>\n\n' +

            '<span style="color:rgb(170,0,0)">\n' +
            '{{uut_name}}: {{uut_readout_fmt}} {{uut_prefix}}{{uut_unit}}  \n' +
            'MPE: {{mpe_fmt}} {{uut_prefix}}{{uut_unit}}  \n' +
            '</span>\n\n' +

            'Error: {{err_fmt}} {{uut_prefix}}{{uut_unit}}  \n\n' +

            '---\n\n' +

            'k: {{k_fmt}}  \n' +
            '&#120642;<sub>eff</sub>: {{veff_fmt}}  \n'
    ###            
    procedure:
      propertyOrder: 5
      type: "string"
      title: "Procedure"
      format: "markdown"
      default: "Write your procedure here..."###

window.reclassificationUncertantiesSchema = uncertainties: $.extend(
        true, 
        {}, 
        window.uncertaintiesSchema.uncertainties, {
          propertyOrder: 5,
          items: {
            properties: {
              correction: {
                type: "string",
                title: "Correction",
                format: "textarea",
                default: "c = 0"
              }
            }
          }
        }
      )

window.reclassificationFormSchema =
  type: "array"
  title: "Reclassification"
  uniqueItems: true
  options:
    collapsed: true       
    disable_array_reorder: true
    disable_array_add: true
  items:
    type: "object"
    title: "Range"
    headerTemplate: "{{ self.name }}: {{ self.limits.start }} .. {{ self.limits.end }} {{ self.unit }} ({% if self.enabled %}enabled{% else %}disabled{% endif %})"
    options:
      collapsed: true
      disable_edit_json: true
      disable_properties: false
    properties:
      enabled:
        title: "Enabled"
        type: "boolean"
        default: false
        propertyOrder: 1
      name:
        title: "Name"
        type: "string"
        default: "New Range"
        options:
          hidden: true
      unit:
        title: "Unit"
        type: "string"
        default: ""
        options:
          hidden: true
      limits:
        title: "limits"
        type: "object"
        default: ""
        options:
          hidden: true
      uncertainties: window.reclassificationUncertantiesSchema.uncertainties
      _identifier:
        type: "string"
        title: "_identifier"
        default: ""
        options:
          hidden: true


window.assetFormSchema = 
  type: "object"
  title: "Asset snippet"
  properties:
    name:
      title: "Name"
      type: "string"
      default: "Description..."
      propertyOrder: 1
    unit:
      title: "Unit"
      type: "string"
      propertyOrder: 2
    kind:
      propertyOrder: 3      
      type: "string"
      title: "Kind"
      enum: [
        "Meter"
        "Source"
        "Fixed"
      ]
      default: "Meter"
    ranges:
      type: "array"
      title: "Ranges"
      uniqueItems: true
      propertyOrder: 3
      items:
        type: "object"
        title: "Range"
        headerTemplate: "{{ self.limits.start }} .. {{ self.limits.end }}"
        options:
          collapsed: true     
          disable_edit_json: true
          disable_properties: false
        properties:
          limits:
            type: "object"
            title: "Range Limits"
            format: "grid"
            propertyOrder: 4
            options:
              collapsed: true     
              disable_edit_json: true
              disable_properties: false
            properties:
              start:
                title: "Range start"
                propertyOrder: 1
                type: "number"
              end:
                title: "Range end"
                propertyOrder: 2
                type: "number"
              fullscale:
                title: "Full Scale"
                propertyOrder: 3
                type: "number"
              autorange_conditions:
                title: "Autorange Conditions"
                propertyOrder: 4
                type: "string"
                format: "textarea"
                default: "((readout >= range_start) and (readout <= range_end)) or is_fixed"
              resolution:
                title: "Resolution"
                propertyOrder: 5
                type: "string"
                default: "0.001e-3"
          nominal_value: 
            title: "Nominal Value"
            type: "string"
            format: "textarea"
            default: "readout = is_fixed ? 0 : readout"
            height: "100px"
          uncertainties: window.uncertaintiesSchema.uncertainties
          _identifier:
            type: "random_number"
            title: "_identifier"
            default: ""
            options:
              hidden: true
    automation:
      type: "code"
      title: "Automation Feats"
      format: "python"
      propertyOrder: 4
      options:
        height: "100px"
      default: "@Feat(None)\n" + 
      "def readout(self):\n" + 
      "    return (self.query('OUT?'))\n\n" +
      "@readout.setter\n" +
      "def readout(self, value):\n" +
      " self.write('OUT {:.8f} V'.format(value))"

window.choosenSnippetsSchema =
  type: "array"
  format: "tabs"
  title: "Chosen snippets"
  options:
    disable_edit_json: true
    disable_properties: true
    disable_collapse: false
    collapsed: true
  items:
    type: "object"
    title: "snippet"
    headerTemplate: "{{ self.label }}"
    options:
      collapsed: true
    properties:
      _tag_list:
        type: "string"
        options:
          hidden: true
      label:
        type: "string"
        title: "Label"
        format: "text"
        propertyOrder: 1
      automation:
        type: "object"
        title: "Automation"
        propertyOrder: 2
        options:
          collapsed: true
        properties:
          visa_address:
            type: "string"
            title: "Visa Address"
            format: "text"
            propertyOrder: 3
          code:
            type: "code"
            title: "Model Automation"
            format: "python"
      asset_id:
        type: "string"
        options: {"hidden": true}
        propertyOrder: 4
      snippet_id:
        type: "string"
        options: {"hidden": true}
        propertyOrder: 5
      model_id:
        type: "string"
        options: {"hidden": true}
        propertyOrder: 6
      position:
        type: "string"
        options: {"hidden": true}
        propertyOrder: 7
      value:
        type: "object"
        title: "Value"
        options:
          collapsed: true
        propertyOrder: 5
        properties:
          $.extend true, {}, window.assetFormSchema.properties, 
            ranges:
              items: 
                properties: 
                  reclassification: 
                    $.extend({}, window.reclassificationUncertantiesSchema.uncertainties, {title: "Reclassification"})


window.spreadsheetEntriesSchema =
  type: "object",
  title: "Data input"
  options:
    disable_edit_json: false
    disable_properties: false
    disable_collapse: true
  properties:
    model: $.extend({}, window.mathFormSchema, {options:{collapsed: true, disable_edit_json: true, disable_properties: true}})
    choosen_snippets: window.choosenSnippetsSchema

window.modelAutomationCodeSchema = 
  options:
    collapsed: true
  type: "object"
  title: "Model Automation"
  properties:
    automation:
      type: "code"
      title: "Automation Class"
      format: "python"
      options:
        height: "200px"
      default: "class Driver(MessageBasedDriver):\n" +
      "    DEFAULTS = {'ASRL': {   'read_termination': '\\n',\n" +
      "                            'baud_rate': 2400}}\n" +
      "    @Feat()\n" +
      "    def operate(self):\n" +
      "        self.write('OPER')\n\n" +
      "    @Feat()\n" +
      "    def standby(self):\n" +
      "        self.write('STBY')"


# Json-editor builder
window.create_json_editor = (selector, schema, opts = {}) ->
  if typeof selector is "object"
    elem = selector
  elem = $.find(selector)
  if elem.length
    $(elem).hide()
    # Create json-editor holder
    json_editor_id = $(elem).attr("id") + "_json_editor"
    $(elem).after("<div></div>")
    json_editor_holder = $(elem).next()
    $(json_editor_holder).attr("id", json_editor_id)
    # Options
    default_options = 
      theme: "bootstrap3"
      iconlib: "bootstrap3"
      disable_collapse: false
      schema: schema
    opts = $.extend(default_options, opts)
    # Create editor
    json_editor = new JSONEditor(json_editor_holder[0], opts)
    # Get string from element
    data_string = $(elem).val()

    data_string_json = {}
    try
      data_string_json = JSON.parse(data_string)
      if not _.isEmpty(data_string_json)
        json_editor.setValue data_string_json
    json_editor.on "change", ->
      data = json_editor.getValue()
      data_json = JSON.stringify(data)
      $(elem).val(data_json)
  return json_editor