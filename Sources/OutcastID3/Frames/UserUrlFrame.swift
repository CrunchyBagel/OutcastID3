//
//  UserUrlFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

extension OutcastID3.Frame {
    public struct UserUrlFrame: OutcastID3TagFrame {
        static let frameIdentifier = "WXXX"
        
        public let encoding: String.Encoding
        public let urlDescription: String
        public let urlString: String
        
        public init(encoding: String.Encoding, urlDescription: String, urlString: String) {
            self.encoding = encoding
            self.urlDescription = urlDescription
            self.urlString = urlString
        }
        
        public var debugDescription: String {
            return "urlString=\(urlString) urlDescription=\(urlDescription)"
        }
        
        public var url: URL? {
            return URL(string: urlString)
        }
    }
}
extension OutcastID3.Frame.UserUrlFrame {
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3, .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: OutcastID3.Frame.UserUrlFrame.frameIdentifier)
        
        try fb.addString(
            str: self.urlDescription,
            encoding: self.encoding,
            includeEncodingByte: true,
            terminator: version.stringTerminator(encoding: self.encoding)
        )
        
        try fb.addString(str: self.urlString, encoding: .isoLatin1, includeEncodingByte: false, terminator: nil)
        
        return try fb.data()
    }
}

extension OutcastID3.Frame.UserUrlFrame {
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        
        var frameContentRangeStart = version.frameHeaderSizeInBytes

        guard frameContentRangeStart < data.count else {
            return nil
        }

        let encoding = String.Encoding.fromEncodingByte(byte: data[frameContentRangeStart], version: version)
        frameContentRangeStart += 1

        let description = data.readString(offset: &frameContentRangeStart, encoding: encoding, terminator: version.stringTerminator(encoding: encoding))
        
        guard frameContentRangeStart < data.count else {
            return nil
        }

        let frameContent = data.subdata(in: frameContentRangeStart ..< data.count)
        
        guard let urlString = String(data: frameContent, encoding: .isoLatin1) else {
            return nil
        }
        
        return OutcastID3.Frame.UserUrlFrame(
            encoding: encoding,
            urlDescription: description ?? "",
            urlString: urlString
        )
    }
}
