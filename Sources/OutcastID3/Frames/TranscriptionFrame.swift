//
//  TranscriptionFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

extension OutcastID3.Frame {
    /// An ID3 unsynchronised lyrics/transcription frame (USLT).
    public struct TranscriptionFrame: OutcastID3TagFrame {
        static let frameIdentifier = "USLT"

        /// The string encoding used for the lyrics text.
        public let encoding: String.Encoding
        /// The ISO 639-2 language code (e.g. "eng").
        public let language: String
        /// A short description of the lyrics content.
        public let lyricsDescription: String
        /// The lyrics or transcription text.
        public let lyrics: String
        
        /// Creates a new transcription frame.
        /// - Parameters:
        ///   - encoding: The string encoding to use.
        ///   - language: The ISO 639-2 language code (e.g. "eng").
        ///   - lyricsDescription: A short description of the lyrics content.
        ///   - lyrics: The lyrics or transcription text.
        public init(encoding: String.Encoding, language: String, lyricsDescription: String, lyrics: String) {
            self.encoding = encoding
            self.language = language
            self.lyricsDescription = lyricsDescription
            self.lyrics = lyrics
        }
    }
}

extension OutcastID3.Frame.TranscriptionFrame {
    /// Serializes this transcription frame to raw data suitable for writing to an ID3 tag.
    /// - Parameter version: The ID3v2 tag version to encode for.
    /// - Returns: The serialized frame data.
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3, .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: OutcastID3.Frame.TranscriptionFrame.frameIdentifier)
        fb.addStringEncodingByte(encoding: self.encoding)
        try fb.addString(str: self.language, encoding: .isoLatin1, includeEncodingByte: false, terminator: nil)
        
        try fb.addString(
            str: self.lyricsDescription,
            encoding: self.encoding,
            includeEncodingByte: false,
            terminator: version.stringTerminator(encoding: self.encoding)
        )
        
        try fb.addString(str: self.lyrics, encoding: self.encoding, includeEncodingByte: false, terminator: nil)
        
        return try fb.data()
    }
}

extension OutcastID3.Frame.TranscriptionFrame {
    /// Parses a transcription frame from raw ID3 tag data.
    /// - Parameters:
    ///   - version: The ID3v2 tag version.
    ///   - data: The raw data for this frame, including the frame header.
    ///   - useSynchSafeFrameSize: Whether to interpret the frame size as synch-safe.
    /// - Returns: A parsed transcription frame, or `nil` if the data does not match.
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {

        var frameContentRangeStart = version.frameHeaderSizeInBytes

        guard frameContentRangeStart < data.count else {
            return nil
        }

        let encoding = String.Encoding.fromEncodingByte(byte: data[frameContentRangeStart], version: version)
        frameContentRangeStart += 1

        let languageLength = 3

        guard frameContentRangeStart + languageLength <= data.count else {
            return nil
        }

        let languageBytes = data.subdata(in: frameContentRangeStart ..< frameContentRangeStart + languageLength)
        
        
        guard let language = String(bytes: languageBytes, encoding: .isoLatin1) else {
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

extension OutcastID3.Frame.TranscriptionFrame: Sendable {}

extension OutcastID3.Frame.TranscriptionFrame: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "language=\(language) lyricsDescription=\(lyricsDescription) length=\(lyrics.count) lyrics=\(lyrics)"
    }
}
