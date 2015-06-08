Pod::Spec.new do |s|
  s.name         = "HACLocationManager"
  s.version      = “1.0.3”
  s.summary      = "Location manager iOS 7 >."
  s.description  = <<-DESC
    The HACLocationManager HACLocationManager is written in Objective-C, very easy to use and effective class.
    Requests are made using blocks. If syntax is very comfortable and intuitive. Use singleton design pattern and its compatibility is complete with iOS7 or higher..
    Get Location, Geocoder & Reverse Geocoding.
    DESC
  s.homepage         = "https://github.com/litoarias/HACLocationManager.git"
  s.license          = { :type => "GNU", :file => "LICENSE" }
  s.authors          = { "litoarias" => "lito.arias.cervero@gmail.com" }
  s.social_media_url = 'https://github.com/litoarias/HACLocationManager'
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/litoarias/HACLocationManager.git", :tag => “1.0.3” }
  s.source_files  = "LocationManager"
  s.requires_arc = true

  s.ios.frameworks = 'CoreLocation','MapKit'

end
