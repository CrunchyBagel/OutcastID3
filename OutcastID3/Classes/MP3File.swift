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
        public let rawFrames: [RawFrame]
    }

    public enum Error: Swift.Error {
        case tagNotFound
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
    func parseID3Tag() throws -> ID3Tag {
        // Read in contents of MP3 file
        
        let data = try Data(contentsOf: localUrl)

        // Read the tag version. Assumes the tag is at the start of the file
        
        guard let id3String = data.subdata(in: 0 ..< 3).toString, id3String == "ID3" else {
            throw Error.tagNotFound
        }
        
        // Check which ID3v2 version was found

        let versionNumber = data[3]
        
        guard let version = ID3Tag.Version(rawValue: versionNumber) else {
            throw Error.unsupportedTagVersion
        }
        
        // Determine the total size of the tag
        
        let tagByteCount = MP3File.parseTagSizeInBytes(data: data, offset: 6)
        
        guard tagByteCount < data.count + version.tagHeaderSizeInBytes else {
            throw Error.corruptedFile
        }
        
        // Read the tag data bytes
        
        let tagData = data.subdata(in: version.tagHeaderSizeInBytes ..< Int(tagByteCount))

        // Parse the tag data into frames
        
        let frames = try MP3File.rawFramesFromData(version: version, data: tagData)

        return ID3Tag(version: version, rawFrames: frames)
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
                
                guard position + frameSize < count else {
                    break
                }

                let frameData = data.subdata(in: position ..< position + frameSize)

                let frame = RawFrame(version: version, data: frameData)
                ret.append(frame)
                
                position += frame.data.count
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
        
        let frameSizePosition = position + version.frameSizeOffsetInBytes
        
        guard frameSizePosition < data.count else {
            throw Error.corruptedFile
        }
        
        var frameSize: UInt32 = 0
        
        let d = data as NSData
        d.getBytes(&frameSize, range: NSMakeRange(frameSizePosition, version.frameSizeByteCount))
        frameSize = frameSize.bigEndian & version.frameSizeMask
        return Int(frameSize) + version.frameHeaderSizeInBytes
    }

    // TODO: This is only 3 bytes in ID3v2.0
    /// Determine the byte count of the tag by parsing in the size bytes from the header
    class func parseTagSizeInBytes(data: Data, offset: Int) -> UInt32 {
        let d = data as NSData
        
        let size = (d.bytes + offset).assumingMemoryBound(to: UInt32.self).pointee.bigEndian;
        let b1 = (size & 0x7F000000) >> 3;
        let b2 = (size & 0x007F0000) >> 2;
        let b3 = (size & 0x00007F00) >> 1;
        let b4 =  size & 0x0000007F;
        
        return UInt32(b1 + b2 + b3 + b4);
    }

}
