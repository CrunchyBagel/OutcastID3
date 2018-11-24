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

public struct RawFrame {
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
            // TODO: Chapter table of contents
            break

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

        case (_, "TALB"):
            return StringFrame.parse(type: .albumTitle, version: version, data: self.data)

        case (_, "TCON"):
            return StringFrame.parse(type: .contentType, version: version, data: self.data)

        case (_, "TCOP"):
            return StringFrame.parse(type: .copyright, version: version, data: self.data)

        case (_, "TDAT"):
            return StringFrame.parse(type: .date, version: version, data: self.data)

        case (_, "TDLY"):
            return StringFrame.parse(type: .playlistDelay, version: version, data: self.data)

        case (_, "TENC"):
            return StringFrame.parse(type: .encodedBy, version: version, data: self.data)

        case (_, "TEXT"):
            return StringFrame.parse(type: .textWriter, version: version, data: self.data)

        case (_, "TFLT"):
            return StringFrame.parse(type: .fileType, version: version, data: self.data)

        case (_, "TIME"):
            return StringFrame.parse(type: .time, version: version, data: self.data)

        case (_, "TIT1"):
            return StringFrame.parse(type: .contentGroupDescription, version: version, data: self.data)

        case (_, "TIT2"):
            return StringFrame.parse(type: .title, version: version, data: self.data)
            
        case (_, "TIT3"):
            return StringFrame.parse(type: .description, version: version, data: self.data)

        case (_, "TKEY"):
            return StringFrame.parse(type: .initialKey, version: version, data: self.data)

        case (_, "TLAN"):
            return StringFrame.parse(type: .audioLanguage, version: version, data: self.data)

        case (_, "TLEN"):
            return StringFrame.parse(type: .length, version: version, data: self.data)

        case (_, "TMED"):
            return StringFrame.parse(type: .mediaType, version: version, data: self.data)

        case (_, "TOAL"):
            return StringFrame.parse(type: .originalTitle, version: version, data: self.data)

        case (_, "TOFN"):
            return StringFrame.parse(type: .originalFilename, version: version, data: self.data)

        case (_, "TOLY"):
            return StringFrame.parse(type: .originalTextWriter, version: version, data: self.data)

        case (_, "TOPE"):
            return StringFrame.parse(type: .originalArtistPerformer, version: version, data: self.data)

        case (_, "TORY"):
            return StringFrame.parse(type: .originalReleaseYear, version: version, data: self.data)

        case (_, "TOWN"):
            return StringFrame.parse(type: .fileOwner, version: version, data: self.data)

        case (_, "TPE1"):
            return StringFrame.parse(type: .leadArtist, version: version, data: self.data)

        case (_, "TPE2"):
            return StringFrame.parse(type: .band, version: version, data: self.data)

        case (_, "TPE3"):
            return StringFrame.parse(type: .conductor, version: version, data: self.data)

        case (_, "TPE4"):
            return StringFrame.parse(type: .interpretedBy, version: version, data: self.data)

        case (_, "TPE5"):
            return StringFrame.parse(type: .partOfASet, version: version, data: self.data)

        case (_, "TPUB"):
            return StringFrame.parse(type: .publisher, version: version, data: self.data)

        case (_, "TRCK"):
            return StringFrame.parse(type: .track, version: version, data: self.data)

        case (_, "TRDA"):
            return StringFrame.parse(type: .recordingDate, version: version, data: self.data)

        case (_, "TRSN"):
            return StringFrame.parse(type: .internetRadioStationName, version: version, data: self.data)

        case (_, "TRSO"):
            return StringFrame.parse(type: .internetRadioStationOwner, version: version, data: self.data)
            
        case (_, "TSIZ"):
            return StringFrame.parse(type: .fileSizeInBytes, version: version, data: self.data)

        case (_, "TSRC"):
            return StringFrame.parse(type: .internationalStandardRecordingCode, version: version, data: self.data)
            
        case (_, "TSSE"):
            return StringFrame.parse(type: .encodingSettings, version: version, data: self.data)
            
        case (_, "TYER"):
            return StringFrame.parse(type: .year, version: version, data: self.data)

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

        case (_, "WCOM"):
            return UrlFrame.parse(type: .commercialInformation, version: version, data: self.data)

        case (_, "WCOP"):
            return UrlFrame.parse(type: .copyrightLegalInformation, version: version, data: self.data)
            
        case (_, "WOAF"):
            return UrlFrame.parse(type: .officialAudioFileWebpage, version: version, data: self.data)
            
        case (_, "WOAR"):
            return UrlFrame.parse(type: .officialArtistPerformerWebpage, version: version, data: self.data)
            
        case (_, "WOAS"):
            return UrlFrame.parse(type: .officialAudioSourceWebpage, version: version, data: self.data)
            
        case (_, "WORS"):
            return UrlFrame.parse(type: .officialInternetRadioStationWebpage, version: version, data: self.data)
            
        case (_, "WPAY"):
            return UrlFrame.parse(type: .payment, version: version, data: self.data)

        case (_, "WPUB"):
            return UrlFrame.parse(type: .officialPublisherWebpage, version: version, data: self.data)

        case (_, "WXXX"):
            return UserUrlFrame.parse(version: version, data: self.data)

        default:
            break
            
        }
        
        print("Unhandled frame ID: \(frameIdentifier)")
        return nil
    }
}

extension String.Encoding {
    static func fromEncodingByte(byte: UInt8, version: MP3File.ID3Tag.Version) -> String.Encoding {

        let encoding: String.Encoding
        
        switch byte {
        case 0x01: encoding = .utf16
        case 0x03: encoding = .utf8
        default: encoding = .isoLatin1
        }
        
        switch (version, encoding) {
        case (.version4, .utf8): return encoding
        case (_, .utf8): return .isoLatin1
        default: return encoding
        }

    }
}

public protocol Frame: CustomDebugStringConvertible {
    
}

// TODO: Remove?
//extension Collection where Element == UInt8 {
//    func toString(encoding: String.Encoding) -> String? {
//        return String(bytes: self, encoding: encoding)
//    }
//}

extension Data {
    func readString(offset: inout Int, encoding: String.Encoding) -> String? {
        // unicode strings are terminated by \0\0, while latin terminated by \0
        
        var bytes: [UInt8] = []

        switch encoding {
        case .utf8, .utf16:
            let startingOffset = offset
            
            while offset < self.count {
                let byte = self[offset]
                
                if byte == 0x0 && offset > startingOffset {
                    if self[offset - 1] == 0x0 {
                        bytes.removeLast()
                        break
                    }
                }
                
                bytes.append(byte)
                offset += 1
            }
            
            offset += 1
            
        case _:
            var byte: UInt8 = self[offset]
            
            while byte != 0x00 {
                bytes.append(byte)
                offset += 1
                byte = self[offset]
            }
            
            offset += 1

        }
        
        return String(bytes: bytes, encoding: encoding)
    }
}
