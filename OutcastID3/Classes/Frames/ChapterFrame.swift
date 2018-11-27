//
//  ChapterFrame.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

public struct ChapterFrame: Frame {
    static let frameIdentifier = "CHAP"
    
    static let nullValue: UInt32 = 0xFFFFFFFF
    
    public let elementId: String
    public let startTime: TimeInterval
    public let endTime: TimeInterval
    public let startByteOffset: UInt32?
    public let endByteOffset: UInt32?
    
    public let subFrames: [Frame]
    
    public var debugDescription: String {
        
        var parts: [String] = [
            "elementId=\(self.elementId)",
            "startTime=\(self.startTime)",
            "endTime=\(self.endTime)"
        ]
        
        if let count = self.startByteOffset {
            parts.append("startByteOffset=\(count)")
        }
        
        if let count = self.endByteOffset {
            parts.append("startByteOffset=\(count)")
        }
        
        if self.subFrames.count > 0 {
            let str = subFrames.compactMap { $0.debugDescription }
            parts.append("subFrames: \(str)")
        }
        
        return parts.joined(separator: " ")
    }
}

extension ChapterFrame {
    public func frameData(version: MP3File.ID3Tag.Version) throws -> Data {
        switch version {
        case .v2_2:
            throw MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: ChapterFrame.frameIdentifier)
        
        try fb.addString(str: self.elementId, encoding: .isoLatin1, includeEncodingByte: false, terminate: true)

        let startTime = UInt32(self.startTime * 1000)
        fb.append(data: startTime.bigEndian.toData)

        let endTime = UInt32(self.endTime * 1000)
        fb.append(data: endTime.bigEndian.toData)
        
        let startOffset = self.startByteOffset ?? ChapterFrame.nullValue
        fb.append(data: startOffset.bigEndian.toData)
        
        let endOffset = self.endByteOffset ?? ChapterFrame.nullValue
        fb.append(data: endOffset.bigEndian.toData)

        for subFrame in self.subFrames {
            let subFrameData = try subFrame.frameData(version: version)
            fb.append(data: subFrameData)
        }
        
        throw MP3File.WriteError.notImplemented
    }
}

extension ChapterFrame {
    public static func parse(version: MP3File.ID3Tag.Version, data: Data) -> Frame? {
        
        let d = data as NSData
        
        var offset = 10
        
        let elementId = data.readString(offset: &offset, encoding: .isoLatin1)
        
        var startTimeMilliseconds: UInt32 = 0
        d.getBytes(&startTimeMilliseconds, range: NSMakeRange(offset, 4))
        
        offset += 4
        
        var endTimeMilliseconds: UInt32 = 0
        d.getBytes(&endTimeMilliseconds, range: NSMakeRange(offset, 4))
        
        offset += 4
        
        var startByteOffset: UInt32 = 0
        d.getBytes(&startByteOffset, range: NSMakeRange(offset, 4))
        
        offset += 4
        
        var endByteOffset: UInt32 = 0
        d.getBytes(&endByteOffset, range: NSMakeRange(offset, 4))
        
        offset += 4
        
        let subFrames: [Frame]

        if offset < data.count {
            do {
                let subFramesData = data.subdata(in: offset ..< data.count)
                subFrames = try MP3File.framesFromData(version: version, data: subFramesData)
            }
            catch {
                subFrames = []
            }
        }
        else {
            subFrames = []
        }
        
        return ChapterFrame(
            elementId: elementId ?? "",
            startTime: TimeInterval(startTimeMilliseconds.bigEndian) / 1000,
            endTime: TimeInterval(endTimeMilliseconds.bigEndian) / 1000,
            startByteOffset: startByteOffset == ChapterFrame.nullValue ? nil : startByteOffset,
            endByteOffset: endByteOffset == ChapterFrame.nullValue ? nil : endByteOffset,
            subFrames: subFrames
        )
    }
}
