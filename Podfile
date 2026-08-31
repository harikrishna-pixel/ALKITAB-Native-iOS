# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'NKJV Bible' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Toast-Swift'
  pod 'IQKeyboardManager'
  pod 'ReachabilitySwift'
  pod 'Zip', '~> 2.1'
  pod 'SDWebImage'
  pod 'Alamofire'
  
#  pod 'Firebase/Crashlytics'
#  pod 'Firebase/Messaging'
  
  
  pod 'FBSDKShareKit'    # Facebook
  
  # Google Ad
    pod 'CircleProgressView', '~> 1.0'
    pod 'Flurry-iOS-SDK/FlurrySDK', '~> 12.1.1'
    pod 'IronSourceSDK'

    pod 'GoogleUserMessagingPlatform'
    
    pod 'UnityAds'
  # Pods for NKJV Bible

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      deployment_target = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
      if deployment_target.nil? || deployment_target.to_f < 15.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
