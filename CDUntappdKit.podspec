Pod::Spec.new do |s|
  s.name = 'CDUntappdKit'
  s.version = '1.1.1'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'An extensive Swift wrapper for the Untappd API.'
  s.description = <<-DESC
  This Swift wrapper covers all possible network endpoints and responses for the Untappd API.
  DESC
  s.homepage         = 'https://github.com/chrisdhaan/CDUntappdKit'
  s.author           = { 'Christopher de Haan' => 'contact@christopherdehaan.me' }
  s.source           = { :git => 'https://github.com/chrisdhaan/CDUntappdKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  s.swift_versions = ['5.3', '5.4', '5.5']
  
  s.source_files = 'Source/*.swift'
  
  s.dependency 'Alamofire', '5.6.1'
end
