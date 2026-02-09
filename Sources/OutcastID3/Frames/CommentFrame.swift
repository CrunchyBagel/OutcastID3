//
//  CommentFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

extension OutcastID3.Frame {
    /// An ID3 comment frame (COMM), containing a language, description, and comment text.
    public struct CommentFrame: OutcastID3TagFrame {
        static let frameIdentifier = "COMM"
        
        /// The string encoding used for the comment text.
        public let encoding: String.Encoding
        /// The ISO 639-2 language code (e.g. "eng").
        public let language: String
        /// A short description of the comment's purpose.
        public let commentDescription: String
        /// The comment text.
        public let comment: String
        
        /// Creates a new comment frame.
        /// - Parameters:
        ///   - encoding: The string encoding to use.
        ///   - language: The ISO 639-2 language code (e.g. "eng").
        ///   - commentDescription: A short description of the comment's purpose.
        ///   - comment: The comment text.
        public init(encoding: String.Encoding, language: String, commentDescription: String, comment: String) {
            self.encoding = encoding
            self.language = language
            self.commentDescription = commentDescription
            self.comment = comment
        }
    }
}

extension OutcastID3.Frame.CommentFrame {
    /// Serializes this comment frame to raw data suitable for writing to an ID3 tag.
    /// - Parameter version: The ID3v2 tag version to encode for.
    /// - Returns: The serialized frame data.
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3, .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: OutcastID3.Frame.CommentFrame.frameIdentifier)
        fb.addStringEncodingByte(encoding: self.encoding)
        try fb.addString(str: self.language, encoding: .isoLatin1, includeEncodingByte: false, terminator: nil)
        
        try fb.addString(
            str: self.commentDescription,
            encoding: self.encoding,
            includeEncodingByte: false,
            terminator: version.stringTerminator(encoding: self.encoding)
        )
        
        try fb.addString(str: self.comment, encoding: self.encoding, includeEncodingByte: false, terminator: nil)
        
        return try fb.data()
    }
}

extension OutcastID3.Frame.CommentFrame {
    /// Parses a comment frame from raw ID3 tag data.
    /// - Parameters:
    ///   - version: The ID3v2 tag version.
    ///   - data: The raw data for this frame, including the frame header.
    ///   - useSynchSafeFrameSize: Whether to interpret the frame size as synch-safe.
    /// - Returns: A parsed comment frame, or `nil` if the data does not match.
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

        let commentDescription = data.readString(offset: &frameContentRangeStart, encoding: encoding, terminator: version.stringTerminator(encoding: encoding))

        let comment: String?
        
        if frameContentRangeStart < data.count {
            let commentData = data.subdata(in: frameContentRangeStart ..< data.count)
            comment = String(data: commentData, encoding: encoding)
        }
        else {
            comment = nil
        }
        
        return OutcastID3.Frame.CommentFrame(
            encoding: encoding,
            language: language,
            commentDescription: commentDescription ?? "",
            comment: comment ?? ""
        )
    }
}

extension OutcastID3.Frame.CommentFrame: Sendable {}

extension OutcastID3.Frame.CommentFrame: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "language=\(language) commentDescription=\(commentDescription) length=\(comment.count) comment=\(comment)"
    }
}
