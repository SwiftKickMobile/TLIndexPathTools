Pod::Spec.new do |s|
  s.name         = "TLIndexPathTools"
  s.version      = "0.4.5"
  s.summary      = "TLIndexPathTools is a small set of classes that can greatly simplify your table and collection views."
  s.description  = <<-DESC
					TLIndexPathTools is a small set of classes that can greatly simplify your table and collection views. Here are some of the awesome things TLIndexPathTools does:
                    DESC
  s.homepage     = "http://tlindexpathtools.com"
  s.license      = { :type => "MIT" }
  s.author       = { "wtmoose" => "wtm@tractablelabs.com" }
  s.source       = { :git => "https://github.com/wtmoose/TLIndexPathTools.git", :tag => '0.4.5' }
  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.source_files = 'TLIndexPathTools/**/*.{h,m}'
  s.frameworks = 'UIKit', 'QuartzCore', 'CoreData', 'Foundation'
  s.requires_arc = true
end
