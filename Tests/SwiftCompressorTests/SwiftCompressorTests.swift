//
//  SwiftCompressorTests.swift
//  SwiftCompressor
//
//  MIT License.
//

import XCTest
@testable import SwiftCompressor

final class SwiftCompressorTests: XCTestCase {
    
    private let lorem = """
 __    _____ _____ _____ _____    _____ _____ _____ _____ _____
|  |  |     | __  |   __|     |  |     |  _  |   __|  |  |     |
|  |__|  |  |    -|   __| | | |  |-   -|   __|__   |  |  | | | |
|_____|_____|__|__|_____|_|_|_|  |_____|__|  |_____|_____|_|_|_|

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
"""
    private var loremData: Data!
    private var bigLoremData: Data!
    
    override func setUp() {
        super.setUp()
        
        loremData = lorem.data(using: .utf8)
        bigLoremData = Array(repeating: lorem, count: 25000)
            .joined(separator: "/")
            .data(using: .utf8)
    }
    
    // MARK: - Compression and decompression
    
    func testCompressionAndDecompressionLZFSE() {
        testCompressionAndCompression(algorithm: .lzfse)
    }
    
    func testCompressionAndDecompressionLZ4() {
        testCompressionAndCompression(algorithm: .lz4)
    }
    
    func testCompressionAndDecompressionZLIB() {
        testCompressionAndCompression(algorithm: .zlib)
    }
    
    func testCompressionAndDecompressionLZMA() {
        testCompressionAndCompression(algorithm: .lzma)
    }
    
    private func testCompressionAndCompression(algorithm: CompressionAlgorithm) {
        let compressedLoremData = try? loremData.compress(algorithm: algorithm)
        let uncompressedLoremData = try? compressedLoremData?.decompress(algorithm: algorithm)
        
        XCTAssertGreaterThan(uncompressedLoremData!.count, compressedLoremData!.count, "The compressed data should be smaller than the uncompressed data.")
        XCTAssertEqual(loremData, uncompressedLoremData!, "The data before compression and after decompression should be the same.")
    }
    
    // MARK: - Buffer size performance comparision
    
    func testPerformance4096() {
        measure {
            testPerformance(bufferSize: 4096)
        }
    }
    
    func testPerformance8192() {
        measure {
            testPerformance(bufferSize: 8192)
        }
    }
    
    func testPerformance16384() {
        measure {
            testPerformance(bufferSize: 16384)
        }
    }
    
    private func testPerformance(bufferSize: size_t) {
        let compressedLoremData = try? bigLoremData.compress(algorithm: .zlib, bufferSize: bufferSize)
        let _ = try? compressedLoremData?.decompress(algorithm: .zlib, bufferSize: bufferSize)
    }
    
    // MARK: - Compression algorithm performance comparision
    
    func testLZFSE() {
        measure {
            test(algorithm: .lzfse)
        }
    }
    
    func testLZ4() {
        measure {
            test(algorithm: .lz4)
        }
    }
    
    func testZLIB() {
        measure {
            test(algorithm: .zlib)
        }
    }
    
    func testLZMA() {
        measure {
            test(algorithm: .lzma)
        }
    }
    
    private func test(algorithm: CompressionAlgorithm) {
        _ = try? bigLoremData.compress(algorithm: algorithm)
    }
}
