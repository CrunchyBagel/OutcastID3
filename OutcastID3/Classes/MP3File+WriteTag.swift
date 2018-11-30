//
//  MP3File+WriteTag.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 30/11/18.
//

import Foundation

extension OutcastID3.MP3File {
    public enum WriteError: Swift.Error {
        case versionMismatch
        case unsupportedTagVersion
        case noFramesFound
        case encodingError
        case stringEncodingError
    }
    
    public func writeID3Tag(tag: OutcastID3.ID3Tag, outputUrl: URL) throws {
        
        switch tag.version {
        case .v2_2:
            throw WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let readHandle = try FileHandle(forReadingFrom: self.localUrl)
        
        FileManager.default.createFile(atPath: outputUrl.path, contents: nil, attributes: nil)
        
        let writeHandle = try FileHandle(forWritingTo: outputUrl)
        
        defer {
            readHandle.closeFile()
            writeHandle.closeFile()
        }
        
        let header = "ID3"
        
        guard var headerBytes = header.data(using: .isoLatin1) else {
            throw WriteError.stringEncodingError
        }
        
        headerBytes.append(tag.version.rawValue)
        headerBytes.append(0x0) // Version minor
        headerBytes.append(0x0) // Flags
        
        var framesData: [Data] = []
        var framesByteCount = 0
        
        for frame in tag.frames {
            do {
                let data = try frame.frameData(version: tag.version)
                framesData.append(data)
                
                framesByteCount += data.count
            }
            catch {
                print("ERROR: \(error)")
                print("FRAME: \(frame)")
            }
        }
        
        // 4 bytes, each of 7 bits
        let s4 = UInt8(framesByteCount & 0x7f)
        let s3 = UInt8((framesByteCount >> 7) & 0x7f)
        let s2 = UInt8((framesByteCount >> 14) & 0x7f)
        let s1 = UInt8((framesByteCount >> 21) & 0x7f)
        
        headerBytes.append(contentsOf: [ s1, s2, s3, s4 ])
        
        writeHandle.write(headerBytes)
        
        for frameData in framesData {
            writeHandle.write(frameData)
        }
        
        do {
            let existingTag = try self.readID3Tag()
            
            // Only read from where the existing tag ends
            readHandle.seek(toFileOffset: existingTag.endingByteOffset + 1)
        }
        catch {
            // Assume no tag, copy entire file
            readHandle.seek(toFileOffset: 0)
        }
        
        let chunkSize = 8192
        
        while true {
            let chunk = readHandle.readData(ofLength: chunkSize)
            
            guard chunk.count > 0 else {
                break
            }
            
            writeHandle.write(chunk)
        }
    }
}

