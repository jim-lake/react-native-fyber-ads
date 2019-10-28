require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
version = package['version']

Pod::Spec.new do |s|
  s.name         = "RNFyberAds"
  s.version      = version
  s.summary      = "RNFyberAds"
  s.description  = <<-DESC
                  React Native Fyber FairBid SDK Bridge
                   DESC
  s.homepage     = "https://github.com/jim-lake/react-native-fyber-ads"
  s.license      = "MIT"
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/jim-lake/react-native-fyber-ads", :tag => "master" }
  s.source_files  = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "FairBidSDK"
end
