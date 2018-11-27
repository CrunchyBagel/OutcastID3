//
//  TranscriptionFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

public struct TranscriptionFrame: Frame {
    public let language: String
    public let lyricsDescription: String?
    public let lyrics: String?
    
    public var debugDescription: String {
        return "language=\(language) lyricsDescription=\(lyricsDescription ?? "nil") lyrics=\(lyrics ?? "nil")"
    }
}

extension TranscriptionFrame {
    public func frameData(version: MP3File.ID3Tag.Version) throws -> Data {
        throw MP3File.WriteError.notImplemented
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
            language: language,
            lyricsDescription: lyricsDescription,
            lyrics: lyrics
        )
    }
    
}
