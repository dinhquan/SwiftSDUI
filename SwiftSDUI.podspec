Pod::Spec.new do |s|
  s.name             = 'SwiftSDUI'
  s.version          = '0.1.0'
  s.summary          = 'JSON-driven, server-driven UI renderer for SwiftUI.'
  s.description      = <<-DESC
SwiftSDUI renders SwiftUI views from JSON: containers, text, images, controls.
It supports parameter interpolation, precise parse errors, typed actions, async
remote JSON loading, disk-only image caching, and custom view injection.
  DESC
  s.homepage         = 'https://github.com/dinhquan/SwiftSDUI'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Quan Nguyen' => 'dinhquan191@gmail.com' }
  s.source           = { :git => 'https://github.com/dinhquan/SwiftSDUI', :tag => s.version.to_s }

  s.swift_versions   = ['5.7', '5.8', '5.9']
  s.platform         = :ios, '15.0'
  s.frameworks       = 'SwiftUI', 'UIKit'

  s.source_files     = 'Source/**/*.{swift}'
end

