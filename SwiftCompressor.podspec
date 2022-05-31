Pod::Spec.new do |s|
    s.name           = 'SwiftCompressor'
    s.version        = '0.3.0'
    s.summary        = 'Compression framework easily'
    s.description    = 'SwiftCompressor lets you use Compression framework easily'
    s.homepage       = 'https://github.com/sochalewski/SwiftCompressor'
    s.license        = 'MIT'
    s.author         = { 'Piotr Sochalewski' => 'sochalewski@gmail.com' }
    s.source         = { :git => 'https://github.com/sochalewski/SwiftCompressor.git', :tag => s.version.to_s }
    s.platforms      = { :ios => '9.0', :osx => '10.11', :watchos => '2.0', :tvos => '9.0' }
    s.source_files   = 'Sources/SwiftCompressor/**/*'
    s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6']
  end