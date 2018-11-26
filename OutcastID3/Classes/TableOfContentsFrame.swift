//
//  TableOfContentsFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 26/11/18.
//

import Foundation

public struct TableOfContentsFrame: Frame {
    public let elementId: String?
    public let isTopLevel: Bool
    public let isOrdered: Bool
    
    public let childElementIds: [String]

    public let subFrames: [RawFrame]
    
    public var debugDescription: String {
        var parts: [String] = []
        
        if let str = self.elementId {
            parts.append("elementId=\(str)")
        }
        
        parts.append("isTopLevel=\(self.isTopLevel)")
        parts.append("isOrdered=\(self.isOrdered)")
        parts.append("childElementIds=\(self.childElementIds)")
        
        if self.subFrames.count > 0 {
            let str = subFrames.compactMap { $0.frame?.debugDescription }
            parts.append("subFrames: \(str)")
        }
        
        return parts.joined(separator: " ")
    }
    
    static func parse(version: MP3File.ID3Tag.Version, data: Data) -> TableOfContentsFrame? {
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

        return TableOfContentsFrame(
            elementId: elementId,
            isTopLevel: isTopLevel,
            isOrdered: isOrdered,
            childElementIds: childElementIds,
            subFrames: subFrames
        )
    }
}
