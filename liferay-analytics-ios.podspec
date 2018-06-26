Pod::Spec.new do |s|
  s.name             = 'liferay-analytics-ios'
  s.version          = '1.0.0'
  s.summary          = 'Swift API Client for Liferay Analytics'
  s.homepage         = "https://github.com/liferay-mobile/liferay-analytics-ios"
  s.license          = {
                         :type => "LPGL 2.1",
                         :file => "LICENSE"
                       }
  s.author           = { 
                        'Allan Melo' => 'allan.melo@liferay.com' 
                       }

  s.source           = { 
                         :git => 'https://github.com/liferay-mobile/liferay-analytics-ios.git', 
                         :tag => s.version.to_s 
                       }

  s.ios.deployment_target = '10.0'
  s.source_files = 'Source/**/*'
  s.swift_version = '4.0'
end
