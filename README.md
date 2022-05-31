# SwiftCompressor

[![Version](https://img.shields.io/cocoapods/v/SwiftCompressor.svg?style=flat)](http://cocoapods.org/pods/SwiftCompressor)
[![License](https://img.shields.io/cocoapods/l/SwiftCompressor.svg?style=flat)](http://cocoapods.org/pods/SwiftCompressor)
[![Platform](https://img.shields.io/cocoapods/p/SwiftCompressor.svg?style=flat)](http://cocoapods.org/pods/SwiftCompressor)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D.svg)](https://www.swift.org/package-manager/)

## Requirements
* iOS 9.0+, macOS 10.11+, watchOS 2.0+, tvOS 9.0+
* Swift 5.x

## Installation

### Package Manager

You can add SwiftCompressor to an Xcode project by adding it as a package dependency.

  1. From the **File** menu, select **Add Packages…**
  2. Enter `https://github.com/sochalewski/SwiftCompressor` into the package repository URL text field.
  3. Add the package to your app target.

### CocoaPods

To integrate SwiftCompressor into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'SwiftCompressor'
```

Then, run the following command:

```bash
$ pod install
```

## Usage

SwiftCompression is a `Data` extension. It lets you easily compress/decompress `Data` objects this way:

```swift
// Create NSData from file
let path = URL(fileURLWithPath: Bundle.main.path(forResource: "lorem", ofType: "txt")!)
let loremData = try? Data(contentsOf: path)

// Compress and then decompress it!
let compressedData = try? loremData?.compress()
let decompressedData = try? compressedData?.decompress()

// You can also choose one of four algorithms and set a buffer size if you want.
// Available algorithms are LZFSE, LZMA, ZLIB and LZ4.
// Compression without parameters uses LZFSE algorithm. Default buffer size is 4096 bytes.
let compressWithLZ4 = try? loremData?.compress(algorithm: .lz4)
let compressWithLZMAReallyBigBuffer = try? loremData?.compress(algorithm: .lzma, bufferSize: 65_536)
```

## Author

Piotr Sochalewski, <a href="http://sochalewski.github.io">sochalewski.github.io</a>

## License

SwiftCompressor is available under the MIT license. See the LICENSE file for more info.
