Pod::Spec.new do |s|
  s.name         = "PKResManager"
  s.version      = "0.1.0"
  s.summary      = "A lightweight, easy-to-use style or theme manager."
  s.homepage     = "https://github.com/passerbycrk/PKResManager"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Passerbycrk" => "passerbycrk@gmail.com" }
  s.source       = { :git => "https://github.com/passerbycrk/PKResManager.git", :tag => "0.1.0" }

  s.ios.deployment_target = '5.0' # minimum SDK
  s.ios.frameworks = 'Foundation', 'UIKit'

  s.requires_arc = true

  s.resources = 'PKResManager/Resource/*.bundle'
  s.source_files = 'PKResManager/*.{h,m}'
  s.subspec 'Core' do |ss|
      ss.source_files = 'PKResManager/Core/*.{h,m}'      
    end
  s.subspec 'UIKit' do |ss|
      ss.source_files = 'PKResManager/UIKit/*.{h,m}'      
    end

end
