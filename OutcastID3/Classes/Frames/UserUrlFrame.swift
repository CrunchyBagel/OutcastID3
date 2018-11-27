//
//  UserUrlFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

public struct UserUrlFrame: Frame {
    public let urlDescription: String?
    public let urlString: String
    
    public var debugDescription: String {
        return "urlString=\(urlString) urlDescription=\(urlDescription ?? "nil")"
    }
    
    public var url: URL? {
        return URL(string: urlString)
    }
}

extension UserUrlFrame {
    public func frameData(version: MP3File.ID3Tag.Version) throws -> Data {
        throw MP3File.WriteError.notImplemented
    }
}

extension UserUrlFrame {
    public static func parse(version: MP3File.ID3Tag.Version, data: Data) -> Frame? {
        
        var frameContentRangeStart = version.frameHeaderSizeInBytes
        
        let encoding = String.Encoding.fromEncodingByte(byte: data[frameContentRangeStart], version: version)
        frameContentRangeStart += 1

        let description = data.readString(offset: &frameContentRangeStart, encoding: encoding)
        
        let frameContent = data.subdata(in: frameContentRangeStart ..< data.count)
        
        guard let str = String(data: frameContent, encoding: .isoLatin1) else {
            return nil
        }
        
        return UserUrlFrame(
            urlDescription: description,
            urlString: str
        )
    }
}
