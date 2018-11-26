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

    public enum Error: Swift.Error {
        case tagNotFound
        case tagVersionNotFound
        case tagSizeNotFound
        case unsupportedTagVersion
        case corruptedFile
        case corruptedHeader
    }
    
    let localUrl: URL

    public init(localUrl: URL) throws {
        self.localUrl = localUrl
    }
}

public extension MP3File {
    // TODO: Not handling extended header properly?
    
    func parseID3Tag() throws -> ID3Tag {
        let fileHandle = try FileHandle(forReadingFrom: self.localUrl)
        
        defer {
            // Will run after function finishes, even for throws
            fileHandle.closeFile()
        }

        // Assumes the ID3 tag is at the start of the file.
        fileHandle.seek(toFileOffset: 0)
        
        let id3String = String(bytes: fileHandle.readData(ofLength: 3), encoding: .isoLatin1)
        
        guard id3String == "ID3" else {
            throw Error.tagNotFound
        }
        
        guard let versionNumber = fileHandle.readData(ofLength: 1).first else {
            throw Error.corruptedHeader
        }
        
        guard let version = ID3Tag.Version(rawValue: versionNumber) else {
            throw Error.tagVersionNotFound
        }
        
        fileHandle.seek(toFileOffset: 6)
        
        let tagSizeBytes = fileHandle.readData(ofLength: 4)
        
        guard tagSizeBytes.count == 4 else {
            throw Error.tagSizeNotFound
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
        
        let rawFrames = try MP3File.rawFramesFromData(version: version, data: tagData)
        
        let frames = rawFrames.compactMap { $0.frame ?? $0 }
        
        return ID3Tag(
            version: version,
            frames: frames
        )
    }
}

extension MP3File {
    class func rawFramesFromData(version: MP3File.ID3Tag.Version, data: Data, throwOnError: Bool = false) throws -> [RawFrame] {
        var ret: [RawFrame] = []
        
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

                let frame = RawFrame(version: version, data: frameData)
                ret.append(frame)
                
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
            throw Error.corruptedFile
        }
        
        var frameSize: UInt32 = 0
        
        (data as NSData).getBytes(&frameSize, range: NSMakeRange(offset, version.frameSizeByteCount))
        
        frameSize = frameSize.bigEndian & version.frameSizeMask
        
        return Int(frameSize) + version.frameHeaderSizeInBytes
    }
}
