//
//  UserUrlFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

public struct UserUrlFrame: Frame {
    static let frameIdentifier = "WXXX"
    
    public let urlDescriptionEncoding: String.Encoding
    public let urlDescription: String
    public let urlString: String
    
    public var debugDescription: String {
        return "urlString=\(urlString) urlDescription=\(urlDescription)"
    }
    
    public var url: URL? {
        return URL(string: urlString)
    }
}

extension UserUrlFrame {
    public func frameData(version: MP3File.ID3Tag.Version) throws -> Data {
        switch version {
        case .v2_2:
            throw MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: UserUrlFrame.frameIdentifier)
        try fb.addEncodedString(str: self.urlDescription, encoding: self.urlDescriptionEncoding, terminate: true)
        try fb.addString(str: self.urlString, encoding: .isoLatin1, includeEncodingByte: false, terminate: false)
        
        return try fb.data()
    }
}

extension UserUrlFrame {
    public static func parse(version: MP3File.ID3Tag.Version, data: Data) -> Frame? {
        
        var frameContentRangeStart = version.frameHeaderSizeInBytes
        
        let encoding = String.Encoding.fromEncodingByte(byte: data[frameContentRangeStart], version: version)
        frameContentRangeStart += 1

        let description = data.readString(offset: &frameContentRangeStart, encoding: encoding)
        
        let frameContent = data.subdata(in: frameContentRangeStart ..< data.count)
        
        guard let urlString = String(data: frameContent, encoding: .isoLatin1) else {
            return nil
        }
        
        return UserUrlFrame(
            urlDescriptionEncoding: encoding,
            urlDescription: description ?? "",
            urlString: urlString
        )
    }
}
