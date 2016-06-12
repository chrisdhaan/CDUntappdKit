#
# Be sure to run `pod lib lint CDUntappdKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CDUntappdKit'
  s.version          = '0.2.1'
  s.summary          = 'An extensive Objective C wrapper for the Untappd API.'
  s.description      = <<-DESC
This Objective C wrapper covers all possible network endpoints and responses for the Untappd developers API.
                       DESC

  s.homepage         = 'https://github.com/chrisdhaan/CDUntappdKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Christopher de Haan' => 'chrisdhaan@gmail.com' }
  s.source           = { :git => 'https://github.com/chrisdhaan/CDUntappdKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/dehaan_solo'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CDUntappdKit/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'Overcoat', '~> 4.0.0-beta.2'
end
