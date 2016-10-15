# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'GhostGab' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GhostGab

  target 'GhostGabTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GhostGabUITests' do
    inherit! :search_paths
    # Pods for testing
  end
   post_install do |installer|
   installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['SWIFT_VERSION'] = "2.3"
      end
    end
  end
  pod 'Firebase'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
end
