Pod::Spec.new do |s|
  s.name             = 'CDUntappdKit'
  s.version          = '1.0.0'
  s.summary          = 'An extensive Swift wrapper for the Untappd API.'
  s.description      = <<-DESC
This Swift wrapper covers all possible network endpoints and responses for the Untappd API.
                       DESC
  s.homepage         = 'https://github.com/chrisdhaan/CDUntappdKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Christopher de Haan' => 'chrisdhaan@gmail.com' }
  s.source           = { :git => 'https://github.com/chrisdhaan/CDUntappdKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/dehaan_solo'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Source/*.swift'
  s.dependency 'AlamofireObjectMapper', '5.0.0'
end
