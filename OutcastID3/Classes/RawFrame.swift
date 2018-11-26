//
//  RawFrame.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

// http://id3.org/id3v2.3.0
// http://id3.org/id3v2-chapters-1.0

public struct RawFrame: Codable {
    public let version: MP3File.ID3Tag.Version
    public let data: Data
    
    public var frameIdentifier: String? {
        let frameIdentifierSize = version.frameIdentifierSizeInBytes
        let frameIdentifierData = [UInt8](self.data.subdata(in: Range(0...frameIdentifierSize - 1)))
        return String(bytes: frameIdentifierData, encoding: .utf8)
    }
    
    public var frame: Frame? {
        guard let frameIdentifier = self.frameIdentifier else {
            return nil
        }
        
        // Check for the basic string types
        
        if let stringType = StringFrame.StringType(rawValue: frameIdentifier) {
            return StringFrame.parse(type: stringType, version: version, data: self.data)
        }
        
        // Check for the basic URL types
        
        if let urlType = UrlFrame.UrlType(rawValue: frameIdentifier) {
            return UrlFrame.parse(type: urlType, version: version, data: self.data)
        }

        // Check for the remaining types
        
        switch (self.version, frameIdentifier) {
        case (_, "AENC"):
            // TODO:
            break
            
        case (_, "APIC"):
            return PictureFrame.parse(version: version, data: self.data)

        case (_, "CHAP"):
            return ChapterFrame.parse(version: version, data: self.data)
            
        case (_, "COMM"):
            return CommentFrame.parse(version: version, data: self.data)

        case (_, "COMR"):
            // TODO:
            break

        case (_, "CTOC"):
            return TableOfContentsFrame.parse(version: version, data: self.data)

        case (_, "ENCR"):
            // TODO:
            break

        case (_, "EQUA"):
            // TODO:
            break

        case (_, "ETCO"):
            // TODO:
            break

        case (_, "GEOB"):
            // TODO:
            break

        case (_, "GRID"):
            // TODO:
            break

        case (_, "IPLS"):
            // TODO:
            break

        case (_, "LINK"):
            // TODO:
            break

        case (_, "MCDI"):
            // TODO:
            break

        case (_, "MLLT"):
            // TODO:
            break

        case (_, "OWNE"):
            // TODO:
            break

        case (_, "PRIV"):
            // TODO:
            break

        case (_, "PCNT"):
            // TODO:
            break

        case (_, "POPM"):
            // TODO:
            break

        case (_, "POSS"):
            // TODO:
            break

        case (_, "RBUF"):
            // TODO:
            break

        case (_, "RVAD"):
            // TODO:
            break

        case (_, "RVRB"):
            // TODO:
            break

        case (_, "SYLT"):
            // TODO:
            break

        case (_, "SYTC"):
            // TODO:
            break

        case (_, "TXXX"):
            // TODO:
            break

        case (_, "UFID"):
            // TODO:
            break

        case (_, "USER"):
            // TODO:
            break

        case (_, "USLT"):
            return TranscriptionFrame.parse(version: version, data: self.data)

        case (_, "WXXX"):
            return UserUrlFrame.parse(version: version, data: self.data)

        default:
            break
            
        }
        
        return nil
    }
}

public protocol Frame: Codable, CustomDebugStringConvertible {
    
}

