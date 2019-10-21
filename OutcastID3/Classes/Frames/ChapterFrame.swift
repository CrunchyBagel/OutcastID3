//
//  ChapterFrame.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

extension OutcastID3.Frame {
    public struct ChapterFrame: OutcastID3TagFrame {
        static let frameIdentifier = "CHAP"
        
        static let nullValue: UInt32 = 0xFFFFFFFF
        
        public let elementId: String
        public let startTime: TimeInterval
        public let endTime: TimeInterval
        public let startByteOffset: UInt32?
        public let endByteOffset: UInt32?
        
        public let subFrames: [OutcastID3TagFrame]
        
        public init(elementId: String, startTime: TimeInterval, endTime: TimeInterval, startByteOffset: UInt32?, endByteOffset: UInt32?, subFrames: [OutcastID3TagFrame]) {
            self.elementId = elementId
            self.startTime = startTime
            self.endTime = endTime
            self.startByteOffset = startByteOffset
            self.endByteOffset = endByteOffset
            self.subFrames = subFrames
        }
        
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
}

extension OutcastID3.Frame.ChapterFrame {
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: OutcastID3.Frame.ChapterFrame.frameIdentifier)
        
        try fb.addString(str: self.elementId, encoding: .isoLatin1, includeEncodingByte: false, terminate: true)

        let startTime = UInt32(self.startTime * 1000)
        fb.append(data: startTime.bigEndian.toData)

        let endTime = UInt32(self.endTime * 1000)
        fb.append(data: endTime.bigEndian.toData)
        
        let startOffset = self.startByteOffset ?? OutcastID3.Frame.ChapterFrame.nullValue
        fb.append(data: startOffset.bigEndian.toData)
        
        let endOffset = self.endByteOffset ?? OutcastID3.Frame.ChapterFrame.nullValue
        fb.append(data: endOffset.bigEndian.toData)

        for subFrame in self.subFrames {
            let subFrameData = try subFrame.frameData(version: version)
            fb.append(data: subFrameData)
        }
        
        return try fb.data()
    }
}

extension OutcastID3.Frame.ChapterFrame {
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        
        let d = data as NSData
        
        var offset = 10
        
        let intSize = 4 // Hard-coded since it's defined by the spec, not by the size of UInt32
//        let intSize = MemoryLayout<UInt32>.size
        
        let encoding: String.Encoding = .isoLatin1
        let terminator = version.stringTerminator(encoding: encoding)
        
        let elementId = data.readString(offset: &offset, encoding: encoding, terminator: terminator)
        
        guard offset + intSize * 4 < data.count else {
            return nil
        }
        
        var startTimeMilliseconds: UInt32 = 0
        d.getBytes(&startTimeMilliseconds, range: NSMakeRange(offset, intSize))
        
        offset += intSize
        
        var endTimeMilliseconds: UInt32 = 0
        d.getBytes(&endTimeMilliseconds, range: NSMakeRange(offset, intSize))
        
        offset += intSize
        
        var startByteOffset: UInt32 = 0
        d.getBytes(&startByteOffset, range: NSMakeRange(offset, intSize))
        
        offset += intSize
        
        var endByteOffset: UInt32 = 0
        d.getBytes(&endByteOffset, range: NSMakeRange(offset, intSize))
        
        offset += intSize
        
        let subFrames: [OutcastID3TagFrame]

        if offset < data.count {
            do {
                let subFramesData = data.subdata(in: offset ..< data.count)
                subFrames = try OutcastID3.ID3Tag.framesFromData(version: version, data: subFramesData, useSynchSafeFrameSize: useSynchSafeFrameSize)
            }
            catch {
                subFrames = []
            }
        }
        else {
            subFrames = []
        }
        
        return OutcastID3.Frame.ChapterFrame(
            elementId: elementId ?? "",
            startTime: TimeInterval(startTimeMilliseconds.bigEndian) / 1000,
            endTime: TimeInterval(endTimeMilliseconds.bigEndian) / 1000,
            startByteOffset: startByteOffset == OutcastID3.Frame.ChapterFrame.nullValue ? nil : startByteOffset,
            endByteOffset: endByteOffset == OutcastID3.Frame.ChapterFrame.nullValue ? nil : endByteOffset,
            subFrames: subFrames
        )
    }
}
