Pod::Spec.new do |s|
  s.name             = 'liferay-analytics-forms-ios'
  s.version          = '1.0.0'
  s.summary          = 'Swift API Client for Liferay Analytics Forms'
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
  s.dependency    'RxCocoa', ' =4.4.1'
  s.dependency    'RxBlocking', '=4.4.1'
  s.dependency    'RxSwift', '=4.4.1'
  s.dependency    'NSObject+Rx', '=4.3.0'
  s.dependency    'liferay-analytics-ios', '=1.0.0'
end
