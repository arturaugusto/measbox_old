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
'
	end
end
