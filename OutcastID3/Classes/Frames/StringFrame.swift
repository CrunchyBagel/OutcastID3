//
//  StringFrame.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

extension OutcastID3.Frame {
    public struct StringFrame: OutcastID3TagFrame {
        public enum StringType: String, Codable {
            case albumTitle                         = "TALB"
            case contentType                        = "TCON"
            case copyright                          = "TCOP"
            case date                               = "TDAT"
            case playlistDelay                      = "TDLY"
            case encodedBy                          = "TENC"
            case textWriter                         = "TEXT"
            case fileType                           = "TFLT"
            case time                               = "TIME"
            case contentGroupDescription            = "TIT1"
            case title                              = "TIT2"
            case description                        = "TIT3"
            case initialKey                         = "TKEY"
            case audioLanguage                      = "TLAN"
            case length                             = "TLEN"
            case mediaType                          = "TMED"
            case originalTitle                      = "TOAL"
            case originalFilename                   = "TOFN"
            case originalTextWriter                 = "TOLY"
            case originalArtistPerformer            = "TOPE"
            case originalReleaseYear                = "TORY"
            case fileOwner                          = "TOWN"
            case leadArtist                         = "TPE1"
            case band                               = "TPE2"
            case composer                           = "TCOM"
            case conductor                          = "TPE3"
            case interpretedBy                      = "TPE4"
            case partOfASet                         = "TPOS"
            case publisher                          = "TPUB"
            case track                              = "TRCK"
            case recordingDate                      = "TRDA"
            case internetRadioStationName           = "TRSN"
            case internetRadioStationOwner          = "TRSO"
            case fileSizeInBytes                    = "TSIZ"
            case internationalStandardRecordingCode = "TSRC"
            case encodingSettings                   = "TSSE"
            case year                               = "TYER"
            
            public var description: String {
                switch self {
                    
                case .title:
                    return "Title"
                case .description:
                    return "Description"
                case .albumTitle:
                    return "Album Title"
                case .leadArtist:
                    return "Lead Artist"
                case .band:
                    return "Band"
                case .composer:
                    return "Composer"
                case .conductor:
                    return "Conductor"
                case .interpretedBy:
                    return "Interpreted By"
                case .publisher:
                    return "Publisher"
                case .length:
                    return "Length"
                case .year:
                    return "Year"
                case .encodedBy:
                    return "Encoded By"
                case .contentType:
                    return "Content Type"
                case .copyright:
                    return "Copyright"
                case .date:
                    return "Date"
                case .playlistDelay:
                    return "Playlist Delay"
                case .textWriter:
                    return "Text Writer"
                case .fileType:
                    return "File Type"
                case .time:
                    return "Time"
                case .contentGroupDescription:
                    return "Content Group Description"
                case .initialKey:
                    return "Initial Key"
                case .audioLanguage:
                    return "Audio Language"
                case .mediaType:
                    return "Media Type"
                case .originalTitle:
                    return "Original Title"
                case .originalFilename:
                    return "Original Filename"
                case .originalTextWriter:
                    return "Original Text Writer"
                case .originalArtistPerformer:
                    return "Original Artist Performer"
                case .originalReleaseYear:
                    return "Original Release Year"
                case .fileOwner:
                    return "File Owner"
                case .partOfASet:
                    return "Part Of A Set"
                case .track:
                    return "Track"
                case .recordingDate:
                    return "Recording Date"
                case .internetRadioStationName:
                    return "Internet Radio Station Name"
                case .internetRadioStationOwner:
                    return "Internet Radio Station Owner"
                case .fileSizeInBytes:
                    return "File Size In Bytes"
                case .internationalStandardRecordingCode:
                    return "International Standard Recording Code (ISRC)"
                case .encodingSettings:
                    return "Encoding Settings"
                }
            }
        }
        
        public let type: StringType
        public let encoding: String.Encoding
        public let str: String
        
        public init(type: StringType, encoding: String.Encoding, str: String) {
            self.type = type
            self.encoding = encoding
            self.str = str
        }
        
        public var debugDescription: String {
            return "str=\(str)"
        }
    }
}

extension OutcastID3.Frame.StringFrame {
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: self.type.rawValue)
        try fb.addEncodedString(str: self.str, encoding: self.encoding, terminate: false)
        
        return try fb.data()
    }
}

extension OutcastID3.Frame.StringFrame {
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        guard let frameIdentifier = data.frameIdentifier(version: version) else {
            return nil
        }
        
        guard let stringType = StringType(rawValue: frameIdentifier) else {
            return nil
        }
        
        return self.parse(type: stringType, version: version, data: data)
    }
    
    public static func parse(type: OutcastID3.Frame.StringFrame.StringType, version: OutcastID3.TagVersion, data: Data) -> OutcastID3TagFrame? {

        var frameContentRangeStart = version.frameHeaderSizeInBytes
        
        let encoding = String.Encoding.fromEncodingByte(byte: data[frameContentRangeStart], version: version)
        frameContentRangeStart += 1
        
        guard frameContentRangeStart < data.count else {
            return nil
        }
        
        let frameContent = data.subdata(in: frameContentRangeStart ..< data.count)
        
        guard let str = String(data: frameContent, encoding: encoding) else {
            return nil
        }
        
        return OutcastID3.Frame.StringFrame(type: type, encoding: encoding, str: str)
    }
}
