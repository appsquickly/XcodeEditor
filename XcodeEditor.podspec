Pod::Spec.new do |s|
  s.name     = 'XcodeEditor'
  s.version  = '1.6.4'
  s.license  = 'Apache2.0'
  s.summary  = 'An API for manipulating Xcode Projects using objective-C.'
  s.homepage = 'https://github.com/jasperblues/XcodeEditor'
  s.author   = { 'Jasper Blues' => 'jasper@appsquick.ly' }
  s.source   = { :git => 'https://github.com/jasperblues/XcodeEditor.git', :tag => 'v1.6.4' }
  s.platform = :osx
  s.source_files = 'Source/*.{h,m}', 'Source/Utils/*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
end
