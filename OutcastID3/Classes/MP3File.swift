//
//  MP3File.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

public class MP3File {
    public struct ID3Tag {
        public let version: Version
        public let frames: [Frame]
    }

    let localUrl: URL

    public init(localUrl: URL) throws {
        self.localUrl = localUrl
    }
}

extension MP3File {
    public enum WriteError: Swift.Error {
        case versionMismatch
        case unsupportedTagVersion
        case notImplemented
        case noFramesFound
        case stringEncodingError
    }
    
    // TODO: Complete this
    public func writeID3Tag(tag: ID3Tag) throws {
        
        var framesData = tag.frames.compactMap { try? $0.frameData(version: tag.version) }
        
        throw WriteError.noFramesFound
    }
}

public extension MP3File {
    public enum ReadError: Swift.Error {
        case tagNotFound
        case tagVersionNotFound
        case tagSizeNotFound
        case unsupportedTagVersion
        case corruptedFile
        case corruptedHeader
    }

    // TODO: Not handling extended header properly?
    
    func readID3Tag() throws -> ID3Tag {
        let fileHandle = try FileHandle(forReadingFrom: self.localUrl)
        
        defer {
            // Will run after function finishes, even for throws
            fileHandle.closeFile()
        }

        // Assumes the ID3 tag is at the start of the file.
        fileHandle.seek(toFileOffset: 0)
        
        let id3String = String(bytes: fileHandle.readData(ofLength: 3), encoding: .isoLatin1)
        
        guard id3String == "ID3" else {
            throw ReadError.tagNotFound
        }
        
        guard let versionNumber = fileHandle.readData(ofLength: 1).first else {
            throw ReadError.corruptedHeader
        }
        
        guard let version = ID3Tag.Version(rawValue: versionNumber) else {
            throw ReadError.tagVersionNotFound
        }
        
        fileHandle.seek(toFileOffset: 6)
        
        let tagSizeBytes = fileHandle.readData(ofLength: 4)
        
        guard tagSizeBytes.count == 4 else {
            throw ReadError.tagSizeNotFound
        }

        // TODO: ID3v2.1 only uses 3 bytes
        
        // 4 bytes, each of 7 bits
        let s1 = UInt32(tagSizeBytes[0] & 0x7f) << 21
        let s2 = UInt32(tagSizeBytes[1] & 0x7f) << 14
        let s3 = UInt32(tagSizeBytes[2] & 0x7f) << 7
        let s4 = UInt32(tagSizeBytes[3] & 0x7f)

        let tagByteCount = Int(s1 + s2 + s3 + s4)

        fileHandle.seek(toFileOffset: UInt64(version.tagHeaderSizeInBytes))
        let tagData = fileHandle.readData(ofLength: tagByteCount)
        
        // Parse the tag data into frames
        
        let frames = try MP3File.framesFromData(version: version, data: tagData)
        
        return ID3Tag(
            version: version,
            frames: frames
        )
    }
}

extension MP3File {
    class func framesFromData(version: MP3File.ID3Tag.Version, data: Data, throwOnError: Bool = false) throws -> [Frame] {
        var ret: [Frame] = []
        
        var position = 0
        
        let count = data.count
        
        while position < count {
            do {
                let frameSize = try determineFrameSize(data: data, position: position, version: version)
                
                guard position + frameSize <= count else {
                    print("Frame size too big position=\(position) + frameSize=\(frameSize) = \(position + frameSize), count=\(count)")
                    break
                }

                let frameData = data.subdata(in: position ..< position + frameSize)

                if let frame = RawFrame.parse(version: version, data: frameData) {
                    ret.append(frame)
                }
                
                position += frameSize// frame.data.count
            }
            catch let e {
                if throwOnError {
                    throw e
                }
                else {
                    break
                }
            }
        }
        
        return ret
    }

    /// Determine the size of the frame that begins at the given position
    
    class func determineFrameSize(data: Data, position: Int, version: MP3File.ID3Tag.Version) throws -> Int {
        
        let offset = position + version.frameSizeOffsetInBytes
        
        guard offset < data.count else {
            throw ReadError.corruptedFile
        }
        
        var frameSize: UInt32 = 0
        
        (data as NSData).getBytes(&frameSize, range: NSMakeRange(offset, version.frameSizeByteCount))
        
        frameSize = frameSize.bigEndian & version.frameSizeMask
        
        return Int(frameSize) + version.frameHeaderSizeInBytes
    }
}
