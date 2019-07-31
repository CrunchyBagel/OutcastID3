//
//  TranscriptionFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

extension OutcastID3.Frame {
    public struct TranscriptionFrame: OutcastID3TagFrame {
        static let frameIdentifier = "USLT"

        public let encoding: String.Encoding
        public let language: String
        public let lyricsDescription: String
        public let lyrics: String
        
        public init(encoding: String.Encoding, language: String, lyricsDescription: String, lyrics: String) {
            self.encoding = encoding
            self.language = language
            self.lyricsDescription = lyricsDescription
            self.lyrics = lyrics
        }
        
        public var debugDescription: String {
            return "language=\(language) lyricsDescription=\(lyricsDescription) lyrics=\(lyrics)"
        }
    }
}

extension OutcastID3.Frame.TranscriptionFrame {
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: OutcastID3.Frame.TranscriptionFrame.frameIdentifier)
        fb.addStringEncodingByte(encoding: self.encoding)
        try fb.addString(str: self.language, encoding: .isoLatin1, includeEncodingByte: false, terminate: false)
        try fb.addString(str: self.lyricsDescription, encoding: self.encoding, includeEncodingByte: false, terminate: true)
        try fb.addEncodedString(str: self.lyrics, encoding: self.encoding, terminate: false)
        
        return try fb.data()
    }
}

extension OutcastID3.Frame.TranscriptionFrame {
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        
        var frameContentRangeStart = version.frameHeaderSizeInBytes
        
        let encoding = String.Encoding.fromEncodingByte(byte: data[frameContentRangeStart], version: version)
        frameContentRangeStart += 1
        
        let languageLength = 3
        let languageBytes = data.subdata(in: frameContentRangeStart ..< frameContentRangeStart + languageLength)
        
        
        guard let language = String(bytes: languageBytes, encoding: .isoLatin1) else {
            print("Unable to read language")
            return nil
        }
        
        frameContentRangeStart += languageLength
        
        let lyricsDescription = data.readString(offset: &frameContentRangeStart, encoding: encoding, terminator: version.stringTerminator(encoding: encoding))
        
        guard frameContentRangeStart < data.count else {
            return nil
        }
        
        let lyricsData = data.subdata(in: frameContentRangeStart ..< data.count)
        let lyrics = String(data: lyricsData, encoding: encoding)
        
        return OutcastID3.Frame.TranscriptionFrame(
            encoding: encoding,
            language: language,
            lyricsDescription: lyricsDescription ?? "",
            lyrics: lyrics ?? ""
        )
    }
}
