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

extension OutcastID3.Frame {
    public struct RawFrame: OutcastID3TagFrame {
        public let version: OutcastID3.TagVersion
        public let data: Data
        
        public init(version: OutcastID3.TagVersion, data: Data) {
            self.version = version
            self.data = data
        }
        
        public var debugDescription: String {
            return "version=\(self.version.rawValue)"
        }
    }
}

extension OutcastID3.Frame.RawFrame {
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        // Since this is raw data, it's likely not compatible with other versions.
        guard version == self.version else {
            throw OutcastID3.MP3File.WriteError.versionMismatch
        }
        
        return self.data
    }
}

extension OutcastID3.Frame.RawFrame {
    public var frameIdentifier: String? {
        return self.data.frameIdentifier(version: self.version)
    }

    public static func parse(version: OutcastID3.TagVersion, data: Data) -> OutcastID3TagFrame? {
        return self.parseKnownFrame(version: version, data: data) ?? OutcastID3.Frame.RawFrame(version: version, data: data)
    }
    
    private static func parseKnownFrame(version: OutcastID3.TagVersion, data: Data) -> OutcastID3TagFrame? {
        guard let frameIdentifier = data.frameIdentifier(version: version) else {
            return nil
        }
        
        // Check for the basic string types
        
        if let stringType = OutcastID3.Frame.StringFrame.StringType(rawValue: frameIdentifier) {
            return OutcastID3.Frame.StringFrame.parse(type: stringType, version: version, data: data)
        }
        
        // Check for the basic URL types
        
        if let urlType = OutcastID3.Frame.UrlFrame.UrlType(rawValue: frameIdentifier) {
            return OutcastID3.Frame.UrlFrame.parse(type: urlType, version: version, data: data)
        }

        // Check for the remaining types
        
        switch (version, frameIdentifier) {
        case (_, "AENC"):
            // TODO:
            break
            
        case (_, OutcastID3.Frame.PictureFrame.frameIdentifier):
            return OutcastID3.Frame.PictureFrame.parse(version: version, data: data)

        case (_, OutcastID3.Frame.ChapterFrame.frameIdentifier):
            return OutcastID3.Frame.ChapterFrame.parse(version: version, data: data)
            
        case (_, OutcastID3.Frame.CommentFrame.frameIdentifier):
            return OutcastID3.Frame.CommentFrame.parse(version: version, data: data)

        case (_, "COMR"):
            // TODO:
            break

        case (_, OutcastID3.Frame.TableOfContentsFrame.frameIdentifier):
            return OutcastID3.Frame.TableOfContentsFrame.parse(version: version, data: data)

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

        case (_, OutcastID3.Frame.TranscriptionFrame.frameIdentifier):
            return OutcastID3.Frame.TranscriptionFrame.parse(version: version, data: data)

        case (_, OutcastID3.Frame.UserUrlFrame.frameIdentifier):
            return OutcastID3.Frame.UserUrlFrame.parse(version: version, data: data)

        default:
            break
            
        }
        
        return nil
    }
}

extension Data {
    func frameIdentifier(version: OutcastID3.TagVersion) -> String? {
        let size = version.frameIdentifierSizeInBytes
        
        guard size < self.count else {
            return nil
        }
        
        let data = [UInt8](self.subdata(in: Range(0...size - 1)))
        return String(bytes: data, encoding: .isoLatin1)
    }
}
