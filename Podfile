inhibit_all_warnings!

xcodeproj 'ReactiveCouchbaseLite'

target 'ReactiveCouchbaseLite' do
	platform :osx, '10.10'
	pod 'ReactiveCocoa', '~> 2.5'
end

target 'ReactiveCouchbaseLiteTests', :exclusive => true do
	pod 'ReactiveCouchbaseLite', :path => '.'
	pod 'OCHamcrest'
	pod 'OCMockito'
end


