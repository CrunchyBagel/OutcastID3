//
//  UserUrlFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

extension OutcastID3.Frame {
    /// An ID3 user-defined URL frame (WXXX), containing a description and URL.
    public struct UserUrlFrame: OutcastID3TagFrame {
        static let frameIdentifier = "WXXX"
        
        /// The string encoding used for the description.
        public let encoding: String.Encoding
        /// A human-readable description of the URL.
        public let urlDescription: String
        /// The URL string value.
        public let urlString: String
        
        /// Creates a new user-defined URL frame.
        /// - Parameters:
        ///   - encoding: The string encoding to use for the description.
        ///   - urlDescription: A human-readable description of the URL.
        ///   - urlString: The URL string value.
        public init(encoding: String.Encoding, urlDescription: String, urlString: String) {
            self.encoding = encoding
            self.urlDescription = urlDescription
            self.urlString = urlString
        }

        public var url: URL? {
            return URL(string: urlString)
        }
    }
}
extension OutcastID3.Frame.UserUrlFrame {
    /// Serializes this user URL frame to raw data suitable for writing to an ID3 tag.
    /// - Parameter version: The ID3v2 tag version to encode for.
    /// - Returns: The serialized frame data.
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
    /// Parses a user-defined URL frame from raw ID3 tag data.
    /// - Parameters:
    ///   - version: The ID3v2 tag version.
    ///   - data: The raw data for this frame, including the frame header.
    ///   - useSynchSafeFrameSize: Whether to interpret the frame size as synch-safe.
    /// - Returns: A parsed user URL frame, or `nil` if the data does not match.
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

extension OutcastID3.Frame.UserUrlFrame: Sendable {}

extension OutcastID3.Frame.UserUrlFrame: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "urlString=\(urlString) urlDescription=\(urlDescription)"
    }
}
