//
//  ChapterFrame.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

public struct ChapterFrame: Frame {
    public let elementId: String?
    public let startTime: TimeInterval
    public let endTime: TimeInterval
    public let startByteOffset: UInt32?
    public let endByteOffset: UInt32?
    
    public let subFrames: [Frame]
    
    public var debugDescription: String {
        
        var parts: [String] = []
        
        if let str = self.elementId {
            parts.append("elementId=\(str)")
        }
        
        parts.append("startTime=\(self.startTime)")
        parts.append("endTime=\(self.endTime)")
        
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
    
    static func parse(version: MP3File.ID3Tag.Version, data: Data) -> ChapterFrame? {
        
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
                let rawFrames = try MP3File.rawFramesFromData(version: version, data: subFramesData)
                
                subFrames = rawFrames.compactMap { $0.frame ?? $0 }
            }
            catch {
                subFrames = []
            }
        }
        else {
            subFrames = []
        }
        
        return ChapterFrame(
            elementId: elementId,
            startTime: TimeInterval(startTimeMilliseconds.bigEndian) / 1000,
            endTime: TimeInterval(endTimeMilliseconds.bigEndian) / 1000,
            startByteOffset: startByteOffset == 0xffffffff ? nil : startByteOffset,
            endByteOffset: endByteOffset == 0xffffffff ? nil : endByteOffset,
            subFrames: subFrames
        )
    }
}
