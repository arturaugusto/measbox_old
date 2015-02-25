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
	format: "table"
	title: "Uncertainties"
	uniqueItems: true
	options:
		collapsed: true
	items:
		type: "object"
		title: "Uncertainty"
		properties:
			name:
				title: "Name"
				type: "string"

			description:
				title: "Description"
				type: "string"

			distribution:
				type: "string"
				title: "Distribution"
				enum: [
					"Rect."
					"Norm."
					"Tiang."
					"U"
				]
				default: "Rect"

			formula:
				title: "Formula"
				type: "string"
				format: "textarea"
				default: "u <- 0.01 * readout"
				height: "100px"

	default: [
		{
			name: "Resolution"
			description: "Half of minimum step size"
			distribution: "Rect."
			formula: "u <- 0.01/2"			
		}
		{
			name: "MPE"
			description: "Maximum Permissible Error"
			distribution: "Rect."
			formula: "u <- 0.01 * readout\nif(is_UUT) mpe <- u"
		}
	]

window.rangesSchema = ranges:
	type: "array"
	title: "Ranges"
	uniqueItems: true
	items:
		type: "object"
		title: "Range"
		headerTemplate: "{{ i1 }}￫ {{ self.name }}"
		#headerTemplate: "{{ self.name }}"
		options:
			collapsed: true			
		properties:
			name:
				title: "Name"
				type: "string"
				default: "New Range"
				propertyOrder: 1

			limits:
				type: "object"
				title: "Range Limits"
				format: "grid"
				propertyOrder: 4
				properties:
					start:
						title: "Range start"
						type: "number"

					end:
						title: "Range end"
						type: "number"

					fullscale:
						title: "Full Scale"
						type: "number"

					autorange_conditions:
						title: "Autorange Conditions"
						type: "string"
						format: "textarea"
						default: "(readout >= range_start) and (readout <= range_end) or is_fixed"

			prefix:
				title: "Prefix"
				type: "string"
				propertyOrder: 5

			unit:
				title: "Unit"
				type: "string"
				propertyOrder: 6

			uncertainty_text:
				title: "Uncertainty Text"
				format: "textarea"
				type: "string"
				propertyOrder: 7

			kind:
				type: "string"
				title: "Kind"
				enum: [
					"Measurement"
					"Source"
					"Fixed"
				]
				default: "Measurement"
			nominal_value: 
				title: "Nominal Value"
				type: "string"
				format: "textarea"
				default: "if (is_fixed) readout <- 0"
				height: "100px"				
			uncertainties: window.uncertaintiesSchema.uncertainties
			reclassifications:
				type: "array"
				title: "Reclassifications"
				uniqueItems: true
				options:
					collapsed: true				
				items:
					type: "object"
					title: "Condition"
					headerTemplate: "{{ i1 }} - {{ self.condition }}"
					properties:
						condition:
							type: "string"
							title: "Condition"
							default: "asset.certificate = '?'"
						uncertainties: window.uncertaintiesSchema.uncertainties
						correction: 
							title: "Correction"
							type: "string"
							format: "textarea"
							default: "correct_readout <- readout + 0"
							height: "100px"
			automation:
				type: "array"
				format: "table"
				title: "Automation Commands"
				uniqueItems: true
				options:
					collapsed: true
				items:
					type: "object"
					title: "Commands"
					properties:
						name:
							type: "string"
							title: "Name"

						Command:
							type: "string"
							title: "Command"