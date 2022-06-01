//
//  Data+Compressor.swift
//  SwiftCompressor
//
//  MIT License.
//

import Foundation
import Compression

/**
 Compression algorithm
 - `.lz4`: Fast compression
 - `.zlib`: Balances between speed and compression
 - `.lzma`: High compression
 - `.lzfse`: Apple-specific high performance compression
 */
@available(iOS 9.0, macOS 10.11, watchOS 2.0, tvOS 9.0, *)
public enum CompressionAlgorithm {
    /**
     The LZ4 compression algorithm, that is recommended for fast compression.
     */
    case lz4
    
    /**
     The zlib compression algorithm, that is recommended for cross-platform compression.
     */
    case zlib
    
    /**
     The LZMA compression algorithm, that is recommended for high-compression ratio.
     */
    case lzma
    
    /**
     Apple’s proprietary compression algorithm, matching the compression ratio of zlib level 5, but with much higher energy efficiency and speed (between 2x and 3x) for both encode and decode operations.
     
     Use LZFSE when compressing a payload for iOS, macOS, watchOS, and tvOS. If you need to compress a payload for another platform (for example, Linux or Windows), use LZ4, LZMA, or zlib.
     */
    case lzfse
}

@available(iOS 9.0, macOS 10.11, watchOS 2.0, tvOS 9.0, *)
public enum CompressionError: Error {
    /**
     The error received when trying to compress/decompress empty data (when length equals zero).
     */
    case emptyData
    
    /**
     The error received when `compression_stream_init` failed. It also fails when trying to decompress `Data` compressed with different compression algorithm or uncompressed raw data.
     */
    case initError
    
    /**
     The error received when `compression_stream_process` failed.
     */
    case processError
}

@available(iOS 9.0, macOS 10.11, watchOS 2.0, tvOS 9.0, *)
extension Data {
    // MARK: - Synchronous
    
    /**
     Compresses the receiver using the given compression algorithm and buffer size.
     - parameter algorithm: one of four compression algorithms to use during compression.
     - parameter bufferSize: the size of buffer in bytes to use during compression.
     - returns: A `Data` object created by encoding the receiver's contents using the provided compression algorithm.
     */
    public func compress(
        algorithm: CompressionAlgorithm = .lzfse,
        bufferSize: size_t = 4096
    ) throws -> Data {
        try compress(
            algorithm: algorithm,
            operation: .compression,
            bufferSize: bufferSize
        )
    }
    
    /**
     Uncompresses the receiver using the given compression algorithm.
     - parameter algorithm: one of four compression algorithms to use during decompression.
     - parameter bufferSize: the size of buffer in bytes to use during decompression.
     - returns: A `Data` object created by decoding the receiver's contents using the provided compression algorithm.
     */
    public func decompress(
        algorithm: CompressionAlgorithm = .lzfse,
        bufferSize: size_t = 4096
    ) throws -> Data {
        try compress(
            algorithm: algorithm,
            operation: .decompression,
            bufferSize: bufferSize
        )
    }
    
    // MARK: - Asynchronous
    
    /**
     Compresses the receiver using the given compression algorithm and buffer size.
     - parameter algorithm: one of four compression algorithms to use during compression.
     - parameter bufferSize: the size of buffer in bytes to use during compression.
     - parameter completion: A `Result` containing the encoded receiver's contents using the provided compression algorithm or an error.
     */
    public func compress(
        algorithm: CompressionAlgorithm = .lzfse,
        bufferSize: size_t = 4096,
        completion: @escaping (Result<Data, CompressionError>) -> Void
    ) {
        DispatchQueue.main.async {
            do {
                let data = try compress(
                    algorithm: algorithm,
                    operation: .compression,
                    bufferSize: bufferSize
                )
                completion(.success(data))
            } catch let error {
                guard let error = error as? CompressionError else { return }
                completion(.failure(error))
            }
        }
    }
    
    /**
     Compresses the receiver using the given compression algorithm and buffer size.
     - parameter algorithm: one of four compression algorithms to use during compression.
     - parameter bufferSize: the size of buffer in bytes to use during compression.
     - returns: A `Data` object created by encoding the receiver's contents using the provided compression algorithm.
     */
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    public func compress(
        algorithm: CompressionAlgorithm = .lzfse,
        bufferSize: size_t = 4096
    ) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation  in
            compress(algorithm: algorithm, bufferSize: bufferSize) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /**
     Uncompresses the receiver using the given compression algorithm.
     - parameter algorithm: one of four compression algorithms to use during decompression.
     - parameter bufferSize: the size of buffer in bytes to use during decompression.
     - parameter completion: A `Result` containing the decoded receiver's contents using the provided compression algorithm or an error.
     */
    public func decompress(
        algorithm: CompressionAlgorithm = .lzfse,
        bufferSize: size_t = 4096,
        completion: @escaping (Result<Data, CompressionError>) -> Void
    ) {
        DispatchQueue.main.async {
            do {
                let data = try compress(
                    algorithm: algorithm,
                    operation: .decompression,
                    bufferSize: bufferSize
                )
                completion(.success(data))
            } catch let error {
                guard let error = error as? CompressionError else { return }
                completion(.failure(error))
            }
        }
    }
    
    /**
     Uncompresses the receiver using the given compression algorithm.
     - parameter algorithm: one of four compression algorithms to use during decompression.
     - parameter bufferSize: the size of buffer in bytes to use during decompression.
     - returns: A `Data` object created by decoding the receiver's contents using the provided compression algorithm.
     */
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    public func decompress(
        algorithm: CompressionAlgorithm = .lzfse,
        bufferSize: size_t = 4096
    ) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation  in
            decompress(algorithm: algorithm, bufferSize: bufferSize) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    // MARK: - Other
    
    private enum Operation {
        case compression
        case decompression
    }
    
    private func compress(
        algorithm: CompressionAlgorithm,
        operation: Operation,
        bufferSize: size_t
    ) throws -> Data {
        // Throw an error when data to (de)compress is empty.
        guard count > 0 else { throw CompressionError.emptyData }
        
        // Variables
        var status: compression_status
        var op: compression_stream_operation
        var flags: Int32
        var compressionAlgorithm: compression_algorithm
        
        // Output data
        let outputData = NSMutableData()
        
        switch algorithm {
        case .lz4:
            compressionAlgorithm = COMPRESSION_LZ4
        case .zlib:
            compressionAlgorithm = COMPRESSION_ZLIB
        case .lzma:
            compressionAlgorithm = COMPRESSION_LZMA
        case .lzfse:
            compressionAlgorithm = COMPRESSION_LZFSE
        }
        
        // Setup stream operation and flags depending on compress/decompress operation type
        switch operation {
        case .compression:
            op = COMPRESSION_STREAM_ENCODE
            flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
        case .decompression:
            op = COMPRESSION_STREAM_DECODE
            flags = 0
        }
        
        // Allocate memory for one object of type compression_stream
        let streamPointer = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
        defer {
            streamPointer.deallocate()
        }
        
        // Stream and its buffer
        var stream = streamPointer.pointee
        let dstBufferPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            dstBufferPointer.deallocate()
        }
        
        // Create the compression_stream and throw an error if failed
        status = compression_stream_init(&stream, op, compressionAlgorithm)
        guard status != COMPRESSION_STATUS_ERROR else {
            throw CompressionError.initError
        }
        defer {
            compression_stream_destroy(&stream)
        }
        
        // Stream setup after compression_stream_init
        withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            let unsafeBufferPointer = buffer.bindMemory(to: UInt8.self)
            stream.src_ptr = unsafeBufferPointer.baseAddress!
        }
        
        stream.src_size = count
        stream.dst_ptr = dstBufferPointer
        stream.dst_size = bufferSize
        
        repeat {
            status = compression_stream_process(&stream, flags)
            
            switch status {
            case COMPRESSION_STATUS_OK:
                if stream.dst_size == 0 {
                    outputData.append(dstBufferPointer, length: bufferSize)
                    
                    stream.dst_ptr = dstBufferPointer
                    stream.dst_size = bufferSize
                }
            case COMPRESSION_STATUS_END:
                if stream.dst_ptr > dstBufferPointer {
                    outputData.append(dstBufferPointer, length: stream.dst_ptr - dstBufferPointer)
                }
            case COMPRESSION_STATUS_ERROR:
                throw CompressionError.processError
            default:
                break
            }
        } while status == COMPRESSION_STATUS_OK
        
        return outputData as Data
    }
}
