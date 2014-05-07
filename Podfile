platform :ios, '6.0'
xcodeproj 'Encore.xcodeproj'
pod 'AFNetworking',	'~> 1.3'
pod 'MBProgressHUD'
pod 'TestFlightSDK'
pod 'FlurrySDK'
pod 'XCDYouTubeVideoPlayerViewController'
#pod 'SAMRateLimit'
pod 'Reachability'
pod 'CMPopTipView', '~> 2.2.0'
pod 'MLPAutoCompleteTextField', '~> 1.5'
# Remove 64-bit build architecture from Pods targets
post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |configuration|
      target.build_settings(configuration.name)['ARCHS'] = '$(ARCHS_STANDARD_32_BIT)'
    end
  end
end