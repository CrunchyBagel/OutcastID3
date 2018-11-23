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

struct RawFrame {
    let version: MP3File.ID3Tag.Version
    let data: Data
    
    var frameIdentifier: String? {
        let frameIdentifierSize = version.frameIdentifierSizeInBytes
        let frameIdentifierData = [UInt8](self.data.subdata(in: Range(0...frameIdentifierSize - 1)))
        return frameIdentifierData.toString
    }
    
    var frame: Frame? {
        switch (self.version, self.frameIdentifier) {
        case (_, "AENC"):
            // TODO:
            break
            
        case (_, "APIC"):
            // TODO: Picture
            break

        case (_, "CHAP"):
            if let chapter = ChapterFrame.parse(version: version, data: self.data) {
                return chapter
            }
            
        case (_, "COMM"):
            //if let str = self.stringFromData {
                // TODO: Has language and more info
                //                return StringFrame(type: .comment, str: str)
            //}
            break

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
            if let str = self.stringFromData {
                return StringFrame(type: .albumTitle, str: str)
            }

        case (_, "TCON"):
            // TODO: The 'Content type', which previously was stored as a one byte numeric value only, is now a numeric string
            break
            
        case (_, "TCOP"):
            // TODO: The 'Copyright message' frame, which must begin with a year and a space character (making five characters), is intended for the copyright holder of the original sound, not the audio file itself. The absence of this frame means only that the copyright information is unavailable or has been removed, and must not be interpreted to mean that the sound is public domain. Every time this field is displayed the field must be preceded with "Copyright © ".
            break
            
        case (_, "TDAT"):
            // TODO: The 'Date' frame is a numeric string in the DDMM format containing the date for the recording. This field is always four characters long.
            break

        case (_, "TDLY"):
            // TODO: The 'Playlist delay' defines the numbers of milliseconds of silence between every song in a playlist. The player should use the "ETC" frame, if present, to skip initial silence and silence at the end of the audio to match the 'Playlist delay' time. The time is represented as a numeric string.
            break

        case (_, "TENC"):
            // TODO: The 'Encoded by' frame contains the name of the person or organisation that encoded the audio file. This field may contain a copyright message, if the audio file also is copyrighted by the encoder.
            break
            
        case (_, "TEXT"):
            // TODO: The 'Lyricist(s)/Text writer(s)' frame is intended for the writer(s) of the text or lyrics in the recording. They are seperated with the "/" character.
            break

        case (_, "TFLT"):
            // TODO: The 'File type' frame indicates which type of audio this tag defines
            break

        case (_, "TIME"):
            // TODO: The 'Time' frame is a numeric string in the HHMM format containing the time for the recording. This field is always four characters long
            break

        case (_, "TIT1"):
            // TODO: The 'Content group description' frame is used if the sound belongs to a larger category of sounds/music. For example, classical music is often sorted in different musical sections (e.g. "Piano Concerto", "Weather - Hurricane")
            break

        case (_, "TIT2"):
            if let str = self.stringFromData {
                return StringFrame(type: .title, str: str)
            }
            
        case (_, "TIT3"):
            if let str = self.stringFromData {
                return StringFrame(type: .description, str: str)
            }

        case (_, "TKEY"):
            // TODO: The 'Initial key' frame contains the musical key in which the sound starts. It is represented as a string with a maximum length of three characters. The ground keys are represented with "A","B","C","D","E", "F" and "G" and halfkeys represented with "b" and "#". Minor is represented as "m". Example "Cbm". Off key is represented with an "o" only.
            break

        case (_, "TLAN"):
            // TODO: The 'Language(s)' frame should contain the languages of the text or lyrics spoken or sung in the audio. The language is represented with three characters according to ISO-639-2. If more than one language is used in the text their language codes should follow according to their usage.
            break

        case (_, "TLEN"):
            // TODO: The 'Length' frame contains the length of the audiofile in milliseconds, represented as a numeric string.
            break

        case (_, "TMED"):
            // TODO: The 'Media type' frame describes from which media the sound originated. This may be a text string or a reference to the predefined media types found in the list below. References are made within "(" and ")" and are optionally followed by a text refinement, e.g. "(MC) with four channels". If a text refinement should begin with a "(" character it should be replaced with "((" in the same way as in the "TCO" frame. Predefined refinements is appended after the media type, e.g. "(CD/A)" or "(VID/PAL/VHS)".

            break

        case (_, "TOAL"):
            // TODO: The 'Original album/movie/show title' frame is intended for the title of the original recording (or source of sound), if for example the music in the file should be a cover of a previously released song.
            break

        case (_, "TOFN"):
            // TODO: The 'Original filename' frame contains the preferred filename for the file, since some media doesn't allow the desired length of the filename. The filename is case sensitive and includes its suffix.
            break

        case (_, "TOLY"):
            // TODO: The 'Original lyricist(s)/text writer(s)' frame is intended for the text writer(s) of the original recording, if for example the music in the file should be a cover of a previously released song. The text writers are seperated with the "/" character.
            break

        case (_, "TOPE"):
            // TODO: The 'Original artist(s)/performer(s)' frame is intended for the performer(s) of the original recording, if for example the music in the file should be a cover of a previously released song. The performers are seperated with the "/" character.
            break

        case (_, "TORY"):
            // TODO: The 'Original release year' frame is intended for the year when the original recording, if for example the music in the file should be a cover of a previously released song, was released. The field is formatted as in the "TYER" frame.

            break

        case (_, "TOWN"):
            // TODO: The 'File owner/licensee' frame contains the name of the owner or licensee of the file and it's contents.
            break

        case (_, "TPE1"):
            if let str = self.stringFromData {
                return StringFrame(type: .leadArtist, str: str)
            }

        case (_, "TPE2"):
            if let str = self.stringFromData {
                return StringFrame(type: .band, str: str)
            }

        case (_, "TPE3"):
            if let str = self.stringFromData {
                return StringFrame(type: .conductor, str: str)
            }

        case (_, "TPE4"):
            if let str = self.stringFromData {
                return StringFrame(type: .interpretedBy, str: str)
            }

        case (_, "TPE5"):
            // TODO: The 'Part of a set' frame is a numeric string that describes which part of a set the audio came from. This frame is used if the source described in the "TALB" frame is divided into several mediums, e.g. a double CD. The value may be extended with a "/" character and a numeric string containing the total number of parts in the set. E.g. "1/2".
            break

        case (_, "TPUB"):
            if let str = self.stringFromData {
                return StringFrame(type: .publisher, str: str)
            }

        case (_, "TRCK"):
            // TODO: The 'Track number/Position in set' frame is a numeric string containing the order number of the audio-file on its original recording. This may be extended with a "/" character and a numeric string containing the total numer of tracks/elements on the original recording. E.g. "4/9".

            break

        case (_, "TRDA"):
            // TODO: The 'Recording dates' frame is a intended to be used as complement to the "TYER", "TDAT" and "TIME" frames. E.g. "4th-7th June, 12th June" in combination with the "TYER" frame.
            break
            
        case (_, "TRSN"):
            // TODO: The 'Internet radio station name' frame contains the name of the internet radio station from which the audio is streamed.
            break
            
        case (_, "TRSO"):
            // TODO: The 'Internet radio station owner' frame contains the name of the owner of the internet radio station from which the audio is streamed.
            break
            
        case (_, "TSIZ"):
            // TODO: The 'Size' frame contains the size of the audiofile in bytes, excluding the ID3v2 tag, represented as a numeric string.
            break
            
        case (_, "TSRC"):
            // TODO: The 'ISRC' frame should contain the International Standard Recording Code (ISRC) (12 characters).
            break
            
        case (_, "TSSE"):
            // TODO: The 'Software/Hardware and settings used for encoding' frame includes the used audio encoder and its settings when the file was encoded. Hardware refers to hardware encoders, not the computer on which a program was run.
            break
            
        case (_, "TYER"):
            // TODO: The 'Year' frame is a numeric string with a year of the recording. This frames is always four characters long (until the year 10000).
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
            // TODO: Unsynchronised lyrics/text
            break

        case (_, "WCOM"):
            // TODO: The 'Commercial information' frame is a URL pointing at a webpage with information such as where the album can be bought. There may be more than one "WCOM" frame in a tag, but not with the same content.
            break

        case (_, "WCOP"):
            // TODO: The 'Copyright/Legal information' frame is a URL pointing at a webpage where the terms of use and ownership of the file is described.
            break
            
        case (_, "WOAF"):
            // TODO: The 'Official audio file webpage' frame is a URL pointing at a file specific webpage.
            break
            
        case (_, "WOAR"):
            // TODO: The 'Official artist/performer webpage' frame is a URL pointing at the artists official webpage. There may be more than one "WOAR" frame in a tag if the audio contains more than one performer, but not with the same content.
            break
            
        case (_, "WOAS"):
            // TODO: The 'Official audio source webpage' frame is a URL pointing at the official webpage for the source of the audio file, e.g. a movie.
            break
            
        case (_, "WORS"):
            // TODO: The 'Official internet radio station homepage' contains a URL pointing at the homepage of the internet radio station.
            break
            
        case (_, "WPAY"):
            // TODO: The 'Payment' frame is a URL pointing at a webpage that will handle the process of paying for this file.
            break

        case (_, "WPUB"):
            // TODO: The 'Publishers official webpage' frame is a URL pointing at the official wepage for the publisher
            break

        case (_, "WXXX"):
            // TODO:
            break

        default:
//            print("Unhandled frame ID: \(self.frameIdentifier)")
            break
            
        }
        
        return nil
    }
}

extension RawFrame {
    var stringFromData: String? {
        let frameContentRangeStart = self.version.frameHeaderSizeInBytes + self.version.encodingSizeInBytes
        let frameContent = self.data.subdata(in: frameContentRangeStart ..< self.data.count)
        
        guard let encoding = self.stringEncoding else {
            return nil
        }
        
        guard let str = String(data: frameContent, encoding: encoding) else {
            return nil
        }
        
        return str.trimmingCharacters(in: CharacterSet(charactersIn: "\0"))
    }

    var stringEncoding: String.Encoding? {
        let encodingBytePosition = self.version.encodingPositionInBytes
        
        guard encodingBytePosition < self.data.count else {
            return nil
        }
        
        let encoding: String.Encoding
        
        switch self.data[encodingBytePosition] {
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

protocol Frame: CustomDebugStringConvertible {
    
}

extension Collection where Element == UInt8 {
    var toString: String? {
        return String(bytes: self, encoding: .utf8)
        //        return self.reduce("") { $0 + String(Character(UnicodeScalar($1))) }
    }
}
