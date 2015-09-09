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
  "styles": ".report_view h3{\n    text-align: center;\n}      \n.report_view table{\n    padding:0;\n    margin-bottom: 20px;\n    border-collapse: collapse;\n    border-spacing: 0;\n    font-size: 100%;\n    font: inherit;\n}\n\n\n.report_view table tr{\n    border-top:1px solid #ccc;\n    background-color:#fff;\n    margin:0;\n    padding:0;\n}\n\n.report_view table tr:nth-child(2n){\n    background-color:#f8f8f8;\n}\n\n.report_view table tr th{\n    font-weight:bold;\n}\n\n.report_view table tr th,\n.report_view table tr td{\n    border:1px solid #ccc;\n    text-align:left;\n    margin:0;\n    padding:6px 13px;\n}\n\n.report_view table tr th>:first-child,\n.report_view table tr td>:first-child{\n    margin-top:0;\n}\n\n.report_view table tr th>:last-child,\n.report_view table tr td>:last-child{\n    margin-bottom:0;\n}\n"
}
'
	end
end
