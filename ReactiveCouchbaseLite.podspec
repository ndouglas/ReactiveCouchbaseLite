Pod::Spec.new do |s|
  s.name         		= "ReactiveCouchbaseLite"
  s.version      		= "1.0.32"
  s.summary      		= "A merger of Reactive Cocoa and Couchbase-Lite."
  s.description  		= <<-DESC
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
  s.homepage     		= "https://github.com/ndouglas/ReactiveCouchbaseLite"
  s.license      		= { :type => "Public Domain", :file => "LICENSE" }
  s.author             		= { "Nathan Douglas" => "ndouglas@devontechnologies.com" }
  s.ios.deployment_target 	= "7.0"
  s.osx.deployment_target 	= "10.8"
  s.source       		= { :git => "https://github.com/ndouglas/ReactiveCouchbaseLite.git", :tag => "1.0.32" }
  s.exclude_files 		= "*.Tests.m", "RCLTestDefinitions.{h,m}"
  s.frameworks			= "Foundation"
  s.dependency 			"ReactiveCocoa"
  s.osx.source_files  		= "*.{h,m}", "Pods/couchbase-lite-osx/CouchbaseLite.framework/Headers/*.h",  "Pods/couchbase-lite-osx/CouchbaseLiteListener.framework/Headers/*.h", 
  s.ios.source_files  		= "*.{h,m}", "Pods/couchbase-lite-ios/CouchbaseLite.framework/Headers/*.h",  "Pods/couchbase-lite-ios/CouchbaseLiteListener.framework/Headers/*.h", 
  s.ios.dependency		"couchbase-lite-ios"
  s.osx.dependency		"couchbase-lite-osx"
  s.ios.dependency		"couchbase-lite-ios/Listener"
  s.osx.dependency		"couchbase-lite-osx/Listener"
end
