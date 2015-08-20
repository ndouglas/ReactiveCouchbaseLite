
xcodeproj 'ReactiveCouchbaseLite'

target 'ReactiveCouchbaseLite' do
	platform :osx, '10.10'
	pod 'ReactiveCocoa'
	pod 'couchbase-lite-osx'
end

target 'ReactiveCouchbaseLiteTests', :exclusive => true do
	pod 'ReactiveCouchbaseLite', :path => '.'
	pod 'OCMockito'
end


