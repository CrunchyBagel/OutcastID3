//
//  CommentFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

public struct CommentFrame: Frame {
    public let language: String
    public let commentDescription: String?
    public let comment: String?
    
    public var debugDescription: String {
        return "language=\(language) commentDescription=\(commentDescription ?? "nil") comment=\(comment ?? "nil")"
    }
    
    static func parse(version: MP3File.ID3Tag.Version, data: Data) -> CommentFrame? {
        
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
            language: language,
            commentDescription: commentDescription,
            comment: comment
        )
    }

}
