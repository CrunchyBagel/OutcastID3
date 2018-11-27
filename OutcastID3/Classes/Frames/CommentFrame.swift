//
//  CommentFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

public struct CommentFrame: Frame {
    static let frameIdentifier = "COMM"
    
    public let encoding: String.Encoding
    public let language: String
    public let commentDescription: String
    public let comment: String
    
    public var debugDescription: String {
        return "language=\(language) commentDescription=\(commentDescription) comment=\(comment)"
    }
}

extension CommentFrame {
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
        try fb.addString(str: self.commentDescription, encoding: self.encoding, includeEncodingByte: false, terminate: true)
        try fb.addEncodedString(str: self.comment, encoding: self.encoding, terminate: false)
        
        return try fb.data()
    }
}

extension CommentFrame {
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
        
        let commentDescription = data.readString(offset: &frameContentRangeStart, encoding: encoding)
        
        let commentData = data.subdata(in: frameContentRangeStart ..< data.count)
        let comment = String(data: commentData, encoding: encoding)
        
        return CommentFrame(
            encoding: encoding,
            language: language,
            commentDescription: commentDescription ?? "",
            comment: comment ?? ""
        )
    }

}
