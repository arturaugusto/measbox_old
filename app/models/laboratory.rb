class Laboratory < ActiveRecord::Base
	has_many :users
	has_many :companies
	has_many :roles
	cattr_accessor :current_id
	extend DeviseOverrides
	validates_uniqueness_of :subdomain
	validates :name,
		presence: true,
		length: { :in => 3..30, message: 'Laboratory name must have 3 to 30 characters.' }
	validates :subdomain,
		presence: true,
		format: { with: /\A[a-z0-9]+\z/, :message => 'Subdomain must be lowercase.' },
		length: { :in => 2..15, :message => 'Subdomain must have 2 to 15 characters.' }
	before_save :default_values
	def default_values
			self.custom_forms ||= 
'
{
  "services": "{\n  \"type\": \"object\",\n  \"title\": \"Calibration Information\",\n  \"properties\": {\n    \"certificates\": {\n      \"type\": \"array\",\n      \"options\": {\n        \"collapsed\": true\n      },\n      \"title\": \"Certificates\",\n      \"format\": \"table\",\n      \"uniqueItems\": true,\n      \"items\": {\n        \"type\": \"object\",\n        \"title\": \"Certificate\",\n        \"properties\": {\n          \"cert_number\": {\n            \"title\": \"Number\",\n            \"type\": \"string\"\n          },\n          \"description\": {\n            \"title\": \"Description\",\n            \"type\": \"string\"\n          }\n        }\n      }\n    },\n    \"enviromental_conditions\": {\n      \"type\": \"object\",\n      \"title\": \"Enviromental\",\n      \"properties\": {\n        \"temperature\": {\n          \"type\": \"string\",\n          \"title\": \"Temperature\"\n        },\n        \"humidity\": {\n          \"title\": \"Humidity\",\n          \"type\": \"string\"\n        },\n        \"pressure\": {\n          \"title\": \"Pressure\",\n          \"type\": \"string\"\n        }\n      },\n      \"options\": {\n        \"collapsed\": \"undefined\"\n      }\n    },\n    \"notes\": {\n      \"type\": \"array\",\n      \"options\": {\n        \"collapsed\": true\n      },\n      \"title\": \"Notes\",\n      \"uniqueItems\": true,\n      \"items\": {\n        \"type\": \"object\",\n        \"title\": \"Note\",\n        \"properties\": {\n          \"note\": {\n            \"title\": \"Note\",\n            \"type\": \"string\",\n            \"format\": \"textarea\"\n          }\n        }\n      }\n    },\n    \"procedures\": {\n      \"type\": \"array\",\n      \"title\": \"Procedures\",\n      \"uniqueItems\": true,\n      \"items\": {\n        \"type\": \"object\",\n        \"title\": \"Procedure\",\n        \"properties\": {\n          \"procedure\": {\n            \"title\": \"Procedure\",\n            \"type\": \"string\",\n            \"enum\": [\n              \"aa\",\n              \"bb\"\n            ]\n          }\n        }\n      },\n      \"options\": {\n        \"collapsed\": true\n      }\n    }\n  }\n}",
  "styles": ".report_view p table div {\n    font-family: \"times\";\n    font-size: 14px;\n}\n.report_view table{\n    min-width:50%;\n    max-width:90%;\n    font: inherit;\n    text-align:left;\n    margin:0;\n}\n\n.report_view td, tr, th{\n    padding:2px 10px;\n    margin:0;\n    font-weight:normal;\n}\n\n.report_view th{\n    border-bottom:1px solid #bbb;\n}\n\n.report_view table{\n    margin:12px;\n    padding-top: 25px;\n    padding-right: 25px;\n    padding-bottom: 25px;\n    padding-left: 25px;    \n}\n"
}
'
	end
end
