//
//  TranscriptionFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

public struct TranscriptionFrame: Frame {
    static let frameIdentifier = "USLT"

    public let encoding: String.Encoding
    public let language: String
    public let lyricsDescription: String
    public let lyrics: String
    
    public var debugDescription: String {
        return "language=\(language) lyricsDescription=\(lyricsDescription) lyrics=\(lyrics)"
    }
}

extension TranscriptionFrame {
    public func frameData(version: MP3File.ID3Tag.Version) throws -> Data {
        switch version {
        case .v2_2:
            throw MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: TranscriptionFrame.frameIdentifier)
        fb.addStringEncodingByte(encoding: self.encoding)
        try fb.addString(str: self.language, encoding: .isoLatin1, includeEncodingByte: false, terminate: false)
        try fb.addString(str: self.lyricsDescription, encoding: self.encoding, includeEncodingByte: false, terminate: true)
        try fb.addEncodedString(str: self.lyrics, encoding: self.encoding, terminate: false)
        
        return try fb.data()
    }
}

extension TranscriptionFrame {
    public static func parse(version: MP3File.ID3Tag.Version, data: Data) -> Frame? {
        
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
        
        let lyricsDescription = data.readString(offset: &frameContentRangeStart, encoding: encoding)
        
        let lyricsData = data.subdata(in: frameContentRangeStart ..< data.count)
        let lyrics = String(data: lyricsData, encoding: encoding)
        
        return TranscriptionFrame(
            encoding: encoding,
            language: language,
            lyricsDescription: lyricsDescription ?? "",
            lyrics: lyrics ?? ""
        )
    }
}
