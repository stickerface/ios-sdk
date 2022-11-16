#
# Be sure to run `pod lib lint StickerFace.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name = 'StickerFaceSDK'
  s.version = '0.11.0'
  s.summary = 'SDK StickerFace for IOS'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description = 'TODO: Add long description of the pod here.'
  
  s.homepage = 'https://github.com/stickerface/ios-sdk'
  # s.screenshots = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Xaker69' => 'max.xaker41@mail.ru' }
  # s.source = { :path => '.' }
  s.source = { :git => 'https://github.com/stickerface/ios-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'
  
  s.source_files = ["Sources/*.swift", "Sources/**/*.swift", "Sources/**/*.[mh]"]
  
  s.public_header_files = [
  'Sources/**/*.h'
  ]
  
  s.resource_bundles = {
    'StickerFace' => ['Sources/Resource/**/*.*'],
  }
  
  s.frameworks = 'UIKit', 'WebKit'
  s.dependency 'SnapKit'
  s.dependency 'Atributika'
  s.dependency 'Kingfisher'
  s.dependency 'IGListKit'
  s.dependency 'PinLayout'
  s.dependency 'Alamofire'
  s.dependency 'SkeletonView', '~> 1.25.1'
  s.dependency 'TelegramStickersImport'
  
end
