Pod::Spec.new do |s|
  s.name         = "TLIndexPathTools"
  s.version      = "0.5.0"
  s.summary      = "TLIndexPathTools is a small set of classes that can greatly simplify your table and collection views."
  s.description  = <<-DESC
					TLIndexPathTools is a small set of classes that can greatly simplify your table and collection views. Here are some of the awesome things TLIndexPathTools does:

					* Organize data into sections with ease (now with blocks!)
					* Calculate and perform animated batch updates (inserts, moves and deletions)
					* Simplify data source and delegate methods via rich data model APIs
					* Provide a simpler alternative to Core Data NSFetchedResultsController
					* Provide base table view and collection view classes with advanced features

					0.5.0
					* Add lightweight generics to the core classes:
					  TLIndexPathDataModel
					  TLIndexPathUpdates
					* #56 Add optional modification comparitor block to TLIndexPathUpdates

                    DESC
  s.homepage     = "http://tlindexpathtools.com"
  s.license      = { :type => "MIT" }
  s.author       = { "wtmoose" => "wtm@tractablelabs.com" }
  s.source       = { :git => "https://github.com/wtmoose/TLIndexPathTools.git", :tag => '0.5.0' }
  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.source_files = 'TLIndexPathTools/**/*.{h,m}'
  s.frameworks = 'UIKit', 'QuartzCore', 'CoreData', 'Foundation'
  s.requires_arc = true
end
