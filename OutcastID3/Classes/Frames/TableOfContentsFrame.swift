//
//  TableOfContentsFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 26/11/18.
//

import Foundation

public struct TableOfContentsFrame: Frame {
    static let frameIdentifier = "CTOC"
    
    public let elementId: String
    public let isTopLevel: Bool
    public let isOrdered: Bool
    
    public let childElementIds: [String]

    public let subFrames: [Frame]
    
    public var debugDescription: String {
        var parts: [String] = [
            "elementId=\(self.elementId)",
            "isTopLevel=\(self.isTopLevel)",
            "isOrdered=\(self.isOrdered)",
            "childElementIds=\(self.childElementIds)"
        ]
        
        if self.subFrames.count > 0 {
            let str = subFrames.compactMap { $0.debugDescription }
            parts.append("subFrames: \(str)")
        }
        
        return parts.joined(separator: " ")
    }
}

extension TableOfContentsFrame {
    public func frameData(version: MP3File.ID3Tag.Version) throws -> Data {
        switch version {
        case .v2_2:
            throw MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: TableOfContentsFrame.frameIdentifier)
        
        try fb.addString(str: self.elementId, encoding: .isoLatin1, includeEncodingByte: false, terminate: true)
        
        var flags: UInt8 = 0
        
        if self.isTopLevel {
            flags += 0x2
        }
        
        if self.isOrdered {
            flags += 0x1
        }
        
        fb.append(byte: flags)

        fb.append(byte: UInt8(self.childElementIds.count))
        
        for elementId in self.childElementIds {
            try fb.addString(str: elementId, encoding: .isoLatin1, includeEncodingByte: false, terminate: true)
        }
        
        for subFrame in self.subFrames {
            let subFrameData = try subFrame.frameData(version: version)
            fb.append(data: subFrameData)
        }

        return try fb.data()
    }
}

extension TableOfContentsFrame {
    public static func parse(version: MP3File.ID3Tag.Version, data: Data) -> Frame? {
        var offset = 10
        let elementId = data.readString(offset: &offset, encoding: .isoLatin1)
        
        let flags = data[offset]
        
        let isTopLevel = (flags & 0x2) > 0
        let isOrdered  = (flags & 0x1) > 0
        
        offset += 1
        
        let numEntries = data[offset]
        offset += 1
        
        var childElementIds: [String] = []
        
        for _ in 0 ..< numEntries {
            guard let str = data.readString(offset: &offset, encoding: .isoLatin1) else {
                continue
            }
            
            childElementIds.append(str)
        }
        
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

        return TableOfContentsFrame(
            elementId: elementId ?? "",
            isTopLevel: isTopLevel,
            isOrdered: isOrdered,
            childElementIds: childElementIds,
            subFrames: subFrames
        )
    }
}
