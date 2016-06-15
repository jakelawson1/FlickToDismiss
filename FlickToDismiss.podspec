Pod::Spec.new do |s|
  s.name         = "FlickToDismiss"
  s.version      = "0.9"
  s.summary      = "A basic UIViewController class that presents a UIView which can be dismissed by flicking it off the screen."
  s.description  = <<-DESC
                  FlickToDismiss is written in Swift and utilises UIKit Dynamics. It allows for a UIView to be flicked off the screen which dismisses the presenting view controller.
                   DESC
  s.homepage     = "https://github.com/jakelawson1/FlickToDismiss"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Jake Lawson" => "jakelawson1@hotmail.com" }
  s.source       = { :git => "https://github.com/jakelawson1/FlickToDismiss.git", :tag => "#{s.version}" }

  s.platform     = :ios, "8.0"

  s.source_files = 'Source/**'
  s.framework    = "UIKit"
end
