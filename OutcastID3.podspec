#
# Be sure to run `pod lib lint OutcastID3.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OutcastID3'
  s.version          = '0.7.0'
  s.summary          = 'A simple Swift library to read ID3 tags from MP3s.'
  s.description      = <<-DESC
Read and write MP3 file ID3 data. Includes support for chapters.
                       DESC

  s.homepage         = 'https://github.com/CrunchyBagel/OutcastID3'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Crunchy Bagel' => 'hello@crunchybagel.com' }
  s.source           = { :git => 'https://github.com/CrunchyBagel/OutcastID3.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/CrunchyBagel'

  s.swift_versions = '5.0'
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '4.0'
  s.osx.deployment_target = '10.11'

  s.source_files = 'Sources/**/*'
end
