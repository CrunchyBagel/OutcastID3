//
//  ChapterFrame.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

struct ChapterFrame: Frame {
    let elementId: String?
    let startTime: TimeInterval
    let endTime: TimeInterval
    let startByteOffset: UInt32?
    let endByteOffset: UInt32?
    
    let subFrames: [RawFrame]
    
    var debugDescription: String {
        let str = subFrames.compactMap { $0.frame?.debugDescription }
        
        return "elementId=\(String(describing: elementId)), startTime=\(startTime), endTime=\(endTime), startByteOffset=\(String(describing: startByteOffset)), endByteOffset=\(String(describing: endByteOffset)) subFrames: \(str)"
    }
    
    static func parse(version: MP3File.ID3Tag.Version, data: Data) -> ChapterFrame? {
        
        let d = data as NSData
        
        var offset = 10
        
        var elementIdBytes: [UInt8] = []
        
        var byte: UInt8 = data[offset]
        
        while byte != 0x00 {
            elementIdBytes.append(byte)
            offset += 1
            byte = data[offset]
        }
        
        offset += 1
        
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
        
        let subFrames: [RawFrame]
        
        if offset < data.count {
            let subFramesData = data.subdata(in: offset ..< data.count)
            do {
                subFrames = try MP3File.rawFramesFromData(version: version, data: subFramesData)
            }
            catch {
                subFrames = []
            }
        }
        else {
            subFrames = []
        }
        
        return ChapterFrame(
            elementId: elementIdBytes.toString,
            startTime: TimeInterval(startTimeMilliseconds.bigEndian) / 1000,
            endTime: TimeInterval(endTimeMilliseconds.bigEndian) / 1000,
            startByteOffset: startByteOffset == 0xffffffff ? nil : startByteOffset,
            endByteOffset: endByteOffset == 0xffffffff ? nil : endByteOffset,
            subFrames: subFrames
        )
    }
}
