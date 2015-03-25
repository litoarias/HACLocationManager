Pod::Spec.new do |s|
  s.name         = "HACLocationManager"
  s.version      = "0.0.1"
  s.summary      = "Location manager iOS 7 >."
  s.description  = <<-DESC
    The HACLocationManager class provides a simple way to manage the tedious process 
    COMPATIBILITY Location Between 8 and iOS 7.
    DESC
  s.homepage         = "https://github.com/litoarias/HACLocationManager.git"
  s.license          = { :type => "GNU", :file => "LICENSE" }
  s.authors          = { "litoarias" => "lito.arias.cervero@gmail.com" }
  s.social_media_url = 'https://github.com/litoarias/HACLocationManager'
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/litoarias/HACLocationManager.git", :tag => "0.0.1" }
  s.source_files  = "LocationManager"
  s.requires_arc = true

  s.ios.frameworks = 'CoreLocation'

end