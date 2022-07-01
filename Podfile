# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'buntan' do
  # ignore all warnings from all pods
  inhibit_all_warnings!

  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'RealmSwift'
  pod 'Firebase/Analytics'
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  # Pods for buntan
  pod 'XLPagerTabStrip', :git => 'https://github.com/xmartlabs/XLPagerTabStrip', :branch => 'master'

  target  'buntanTests' do
          inherit! :search_paths
          pod 'Firebase'
      end

end
