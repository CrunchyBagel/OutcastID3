//
//  UrlFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

extension OutcastID3.Frame {
    /// An ID3 URL frame linking to an external web resource.
    public struct UrlFrame: OutcastID3TagFrame {
        /// Identifies which URL field this frame represents, mapped to its ID3 frame identifier.
        public enum UrlType: String, Codable {
            case commercialInformation               = "WCOM"
            case copyrightLegalInformation           = "WCOP"
            case officialAudioFileWebpage            = "WOAF"
            case officialArtistPerformerWebpage      = "WOAR"
            case officialAudioSourceWebpage          = "WOAS"
            case officialInternetRadioStationWebpage = "WORS"
            case payment                             = "WPAY"
            case officialPublisherWebpage            = "WPUB"
        }
        
        /// The type of URL field this frame represents.
        public let type: UrlType
        /// The URL string value of this frame.
        public let urlString: String
        
        /// Creates a new URL frame.
        /// - Parameters:
        ///   - type: The type of URL field.
        ///   - urlString: The URL string value.
        public init(type: UrlType, urlString: String) {
            self.type = type
            self.urlString = urlString
        }

        public var url: URL? {
            return URL(string: urlString)
        }
    }
}

extension OutcastID3.Frame.UrlFrame {
    /// Serializes this URL frame to raw data suitable for writing to an ID3 tag.
    /// - Parameter version: The ID3v2 tag version to encode for.
    /// - Returns: The serialized frame data.
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3, .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: self.type.rawValue)
        try fb.addString(str: self.urlString, encoding: .isoLatin1, includeEncodingByte: false, terminator: nil)
        
        return try fb.data()
    }
}

extension OutcastID3.Frame.UrlFrame {
    /// Parses a URL frame from raw ID3 tag data.
    /// - Parameters:
    ///   - version: The ID3v2 tag version.
    ///   - data: The raw data for this frame, including the frame header.
    ///   - useSynchSafeFrameSize: Whether to interpret the frame size as synch-safe.
    /// - Returns: A parsed URL frame, or `nil` if the data does not match.
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        guard let frameIdentifier = data.frameIdentifier(version: version) else {
            return nil
        }

        guard let urlType = UrlType(rawValue: frameIdentifier) else {
            return nil
        }

        return self.parse(type: urlType, version: version, data: data, useSynchSafeFrameSize: useSynchSafeFrameSize)
    }

    /// Parses a URL frame of a known type from raw ID3 tag data.
    /// - Parameters:
    ///   - type: The URL type to parse as.
    ///   - version: The ID3v2 tag version.
    ///   - data: The raw data for this frame, including the frame header.
    ///   - useSynchSafeFrameSize: Whether to interpret the frame size as synch-safe.
    /// - Returns: A parsed URL frame, or `nil` if parsing fails.
    public static func parse(type: UrlType, version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        
        let offset = version.frameHeaderSizeInBytes
        
        guard offset < data.count else {
            return nil
        }
        
        let frameContent = data.subdata(in: offset ..< data.count)
        
        guard let str = String(data: frameContent, encoding: .isoLatin1) else {
            return nil
        }
        
        return OutcastID3.Frame.UrlFrame(type: type, urlString: str)
    }
}

extension OutcastID3.Frame.UrlFrame: Sendable {}

extension OutcastID3.Frame.UrlFrame: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "urlString=\(urlString)"
    }
}

extension OutcastID3.Frame.UrlFrame.UrlType: Sendable {}
extension OutcastID3.Frame.UrlFrame.UrlType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .commercialInformation:
            return "Commercial Information"
        case .copyrightLegalInformation:
            return "Copyright/Legal Information"
        case .officialAudioFileWebpage:
            return "Official Audio File Webpage"
        case .officialArtistPerformerWebpage:
            return "Official Artist/Performer Webpage"
        case .officialAudioSourceWebpage:
            return "Official Audio Source Webpage"
        case .officialInternetRadioStationWebpage:
            return "Official Internet Radio Station Webpage"
        case .officialPublisherWebpage:
            return "Official Publisher Webpage"
        case .payment:
            return "Payment"
        }
    }
}
