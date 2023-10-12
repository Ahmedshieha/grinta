# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GrintaTask' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GrintaTask
  pod 'SDWebImage'
  pod 'Alamofire'
  pod 'NVActivityIndicatorView'
  pod 'AlamofireEasyLogger'
  pod 'SwiftyJSON'
  pod 'MOLH'
  pod 'SkeletonView'
  pod 'Moya'
  
  
  post_install do |installer|
        
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["ENABLE_BITCODE"] = "No"
      end
    end
    
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      config.build_settings["VALID_ARCHS"] = "arm64 arm64e armv7 armv7s x86_64"
    end
    
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
      end
    end
    
    #  installer.pods_project.targets.each do |target|
    #    target.build_configurations.each do |config|
    #    end
    #  end
    
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
end
