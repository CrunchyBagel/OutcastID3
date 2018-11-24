//
//  StringFrame.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

public struct StringFrame: Frame {
    public enum StringType {
        case title
        case description
        case comment
        case albumTitle
        case leadArtist
        case band
        case conductor
        case interpretedBy
        case publisher
        case length
        case year
        case encodedBy
        case contentType
        case copyright
        case date
        case playlistDelay
        case textWriter
        case fileType
        case time
        case contentGroupDescription
        case initialKey
        case audioLanguage
        case mediaType
        case originalTitle
        case originalFilename
        case originalTextWriter
        case originalArtistPerformer
        case originalReleaseYear
        case fileOwner
        case partOfASet
        case track
        case recordingDate
        case internetRadioStationName
        case internetRadioStationOwner
        case fileSizeInBytes
        case internationalStandardRecordingCode
        case encodingSettings
        
        public var description: String {
            switch self {
                
            case .title:
                return "Title"
            case .description:
                return "Description"
            case .comment:
                return "Comment"
            case .albumTitle:
                return "Album Title"
            case .leadArtist:
                return "Lead Artist"
            case .band:
                return "Band"
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
    public let str: String
    
    public var debugDescription: String {
        return "str=\(str)"
    }
    
    static func parse(type: StringType, version: MP3File.ID3Tag.Version, data: Data) -> StringFrame? {

        var frameContentRangeStart = version.frameHeaderSizeInBytes
        
        let encoding = String.Encoding.fromEncodingByte(byte: data[frameContentRangeStart], version: version)
        frameContentRangeStart += 1
        
        let frameContent = data.subdata(in: frameContentRangeStart ..< data.count)
        
        guard let str = String(data: frameContent, encoding: encoding) else {
            return nil
        }
        
        return StringFrame(type: type, str: str)
    }
}
