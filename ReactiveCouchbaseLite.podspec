Pod::Spec.new do |s|
  s.name         			= "ReactiveCouchbaseLite"
  s.version      			= "1.0.40"
  s.summary      			= "A merger of Reactive Cocoa and Couchbase-Lite."
  s.description  			= <<-DESC
					A merger of Reactive Cocoa and Couchbase-Lite.
	
					In the course of working with ReactiveCocoa and Couchbase-Lite together on a major 
					project, I generated a decent amount of useful code that could be separated out 
					from the project and made useful to other developers. I'm working on this task here.

					I'm not expecting this to be a major undertaking, since a lot of this code is 
					already written and tested, but I am cleaning it up and refactoring a bit, and 
					making it a bit more comprehensive, so please bear with me.

					My highest priorities are correctness, thread-safety (I'm trying to make the 
					interface completely thread-agnostic), and performance on large datasets (as large 
					as CBL can comfortably operate).

					Questions, comments, pull requests, and so forth are welcomed and greatly 
					appreciated. Development is active as of December 8, 2014 and expected to continue 
					through the foreseeable future. It will probably be deprecated when ReactiveCocoa 2 
					is.
	                	   	DESC
  s.homepage     			= "https://github.com/ndouglas/ReactiveCouchbaseLite"
  s.license      			= { :type => "Public Domain", :file => "LICENSE" }
  s.author             			= { "Nathan Douglas" => "ndouglas@devontechnologies.com" }
  s.ios.deployment_target 		= "7.0"
  s.osx.deployment_target 		= "10.8"
  s.source       			= { :git => "https://github.com/ndouglas/ReactiveCouchbaseLite.git", :tag => "1.0.40" }
  s.subspec 'Core' do |cs|
  	cs.exclude_files 		= "*.Tests.m", "RCLTestDefinitions.{h,m}"
  	cs.osx.source_files  		= "*.{h,m}", "vendor/osx/CouchbaseLite.framework/Headers/*.h",  "vendor/osx/CouchbaseLiteListener.framework/Headers/*.h", 
  	cs.ios.source_files  		= "*.{h,m}", "vendor/ios/CouchbaseLite.framework/Headers/*.h",  "vendor/ios/CouchbaseLiteListener.framework/Headers/*.h", 
  	cs.frameworks			= "Foundation"
  	cs.ios.frameworks		= "CFNetwork", "Security"
  	cs.ios.libraries		= "sqlite3", "z"
  	cs.osx.preserve_paths 		= "vendor/osx/CouchbaseLite.framework", "vendor/osx/CouchbaseLiteListener.framework"
  	cs.ios.preserve_paths 		= "vendor/ios/CouchbaseLite.framework", "vendor/ios/CouchbaseLiteListener.framework"
  	cs.osx.vendored_frameworks	= "vendor/osx/CouchbaseLite.framework", "vendor/osx/CouchbaseLiteListener.framework"
  	cs.ios.vendored_frameworks	= "vendor/ios/CouchbaseLite.framework", "vendor/ios/CouchbaseLiteListener.framework"
  	cs.osx.resources		= "vendor/osx/CouchbaseLite.framework", "vendor/osx/CouchbaseLiteListener.framework"
  	cs.ios.resources		= "vendor/ios/CouchbaseLite.framework", "vendor/ios/CouchbaseLiteListener.framework"
  	cs.xcconfig 			= { 'LD_RUNPATH_SEARCH_PATHS' => '@loader_path/../Frameworks' }
	cs.dependency 			"ReactiveCocoa"
  end
  s.subspec 'Tests' do |ts|
	ts.source_files			= "RCLTestDefinitions.{h,m}"
	ts.frameworks			= "XCTest"
	ts.dependency			"OCMockito"
	ts.dependency			"OCHamcrest"
	ts.dependency			"ReactiveCouchbaseLite"
  end
  s.default_subspec			= 'Core'
end
