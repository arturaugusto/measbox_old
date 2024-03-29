#WickedPdf.config = {
#  :wkhtmltopdf => (Rails.env.test? || Rails.env.development? ? Rails.root.join('bin', 'wkhtmltopdf').to_s : Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s),
#  :exe_path => (Rails.env.test? || Rails.env.development? ? Rails.root.join('bin', 'wkhtmltopdf').to_s : Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s),
#}

WickedPdf.config do |config|  
  if Rails.env == 'production' then
    config.exe_path = Rails.root.to_s + "/bin/wkhtmltopdf"
  else  ### Following allows for development on my MacBook or Linux box
    if /darwin/ =~ RUBY_PLATFORM then
      config.exe_path = '/usr/local/bin/wkhtmltopdf' 
    elsif /linux/ =~ RUBY_PLATFORM then
      config.exe_path = '/usr/bin/wkhtmltopdf' 
    else
      raise "UnableToLocateWkhtmltopdf"
    end
  end
end