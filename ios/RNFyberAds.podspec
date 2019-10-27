
Pod::Spec.new do |s|
  s.name         = "RNFyberAds"
  s.version      = "1.0.0"
  s.summary      = "RNFyberAds"
  s.description  = <<-DESC
                  React Native Fyber Fairbid
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  s.author       = { "author" => "jim@blueskylabs.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/jim-lake/react-native-fyber-ads.git", :tag => "master" }
  s.source_files = "ios/RNFyberAds/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  s.dependency "FairBidSDK"

end
