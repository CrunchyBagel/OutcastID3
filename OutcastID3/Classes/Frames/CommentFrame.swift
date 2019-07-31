//
//  CommentFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

extension OutcastID3.Frame {
    public struct CommentFrame: OutcastID3TagFrame {
        static let frameIdentifier = "COMM"
        
        public let encoding: String.Encoding
        public let language: String
        public let commentDescription: String
        public let comment: String
        
        public init(encoding: String.Encoding, language: String, commentDescription: String, comment: String) {
            self.encoding = encoding
            self.language = language
            self.commentDescription = commentDescription
            self.comment = comment
        }
        public var debugDescription: String {
            return "language=\(language) commentDescription=\(commentDescription) comment=\(comment)"
        }
    }
}

extension OutcastID3.Frame.CommentFrame {
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
        try fb.addString(str: self.commentDescription, encoding: self.encoding, includeEncodingByte: false, terminate: true)
        try fb.addEncodedString(str: self.comment, encoding: self.encoding, terminate: false)
        
        return try fb.data()
    }
}

extension OutcastID3.Frame.CommentFrame {
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
