Pod::Spec.new do |s|
  s.name = 'CDUntappdKit'
  s.version = '2.0.0'
  s.cocoapods_version = '>= 1.13.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'An extensive Swift wrapper for the Untappd API.'
  s.description = <<-DESC
    This Swift wrapper covers all possible network endpoints and responses for the Untappd API.
  DESC
  s.homepage = 'https://github.com/chrisdhaan/CDUntappdKit'
  s.author = { 'Christopher de Haan' => 'contact@christopherdehaan.me' }
  s.source = { :git => 'https://github.com/chrisdhaan/CDUntappdKit.git', :tag => s.version.to_s }
  s.documentation_url = 'https://chrisdhaan.github.io/CDUntappdKit/'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '4.0'
  s.visionos.deployment_target = '1.0'

  s.swift_versions = ['5']

  s.source_files = 'Source/*.swift'
  s.resource_bundles = { 'CDUntappdKit' => ['Source/PrivacyInfo.xcprivacy'] }

  s.framework = 'Foundation'
  s.ios.framework  = 'UIKit'
  s.osx.framework  = 'Cocoa'
  s.tvos.framework  = 'UIKit'
  s.watchos.framework  = 'UIKit'
  s.visionos.framework  = 'UIKit'

  s.dependency 'Alamofire', '~> 5.9'
end
