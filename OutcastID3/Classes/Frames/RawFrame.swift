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

    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        return self.parseKnownFrame(version: version, data: data, useSynchSafeFrameSize: useSynchSafeFrameSize) ?? OutcastID3.Frame.RawFrame(version: version, data: data)
    }
    
    // TODO: Finish all the unhandled frame types
    
    private static func parseKnownFrame(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        guard let frameIdentifier = data.frameIdentifier(version: version) else {
            return nil
        }
        
        // Check for the basic string types
        
        if let stringType = OutcastID3.Frame.StringFrame.StringType(rawValue: frameIdentifier) {
            return OutcastID3.Frame.StringFrame.parse(type: stringType, version: version, data: data)
        }
        
        // Check for the basic URL types
        
        if let urlType = OutcastID3.Frame.UrlFrame.UrlType(rawValue: frameIdentifier) {
            return OutcastID3.Frame.UrlFrame.parse(type: urlType, version: version, data: data, useSynchSafeFrameSize: useSynchSafeFrameSize)
        }

        // Check for the remaining types
        
        switch (version, frameIdentifier) {
        case (_, "AENC"):
            break
            
        case (_, OutcastID3.Frame.PictureFrame.frameIdentifier):
            return OutcastID3.Frame.PictureFrame.parse(version: version, data: data, useSynchSafeFrameSize: useSynchSafeFrameSize)

        case (_, OutcastID3.Frame.ChapterFrame.frameIdentifier):
            return OutcastID3.Frame.ChapterFrame.parse(version: version, data: data, useSynchSafeFrameSize: useSynchSafeFrameSize)
            
        case (_, OutcastID3.Frame.CommentFrame.frameIdentifier):
            return OutcastID3.Frame.CommentFrame.parse(version: version, data: data, useSynchSafeFrameSize: useSynchSafeFrameSize)

        case (_, "COMR"):
            break

        case (_, OutcastID3.Frame.TableOfContentsFrame.frameIdentifier):
            return OutcastID3.Frame.TableOfContentsFrame.parse(version: version, data: data, useSynchSafeFrameSize: useSynchSafeFrameSize)

        case (_, "ENCR"):
            break

        case (_, "EQUA"):
            break

        case (_, "ETCO"):
            break

        case (_, "GEOB"):
            break

        case (_, "GRID"):
            break

        case (_, "IPLS"):
            break

        case (_, "LINK"):
            break

        case (_, "MCDI"):
            break

        case (_, "MLLT"):
            break

        case (_, "OWNE"):
            break

        case (_, "PRIV"):
            break

        case (_, "PCNT"):
            break

        case (_, "POPM"):
            break

        case (_, "POSS"):
            break

        case (_, "RBUF"):
            break

        case (_, "RVAD"):
            break

        case (_, "RVRB"):
            break

        case (_, "SYLT"):
            break

        case (_, "SYTC"):
            break

        case (_, "TXXX"):
            break

        case (_, "UFID"):
            break

        case (_, "USER"):
            break

        case (_, OutcastID3.Frame.TranscriptionFrame.frameIdentifier):
            return OutcastID3.Frame.TranscriptionFrame.parse(version: version, data: data, useSynchSafeFrameSize: useSynchSafeFrameSize)

        case (_, OutcastID3.Frame.UserUrlFrame.frameIdentifier):
            return OutcastID3.Frame.UserUrlFrame.parse(version: version, data: data, useSynchSafeFrameSize: useSynchSafeFrameSize)

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
