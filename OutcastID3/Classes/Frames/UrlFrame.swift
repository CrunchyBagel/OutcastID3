//
//  UrlFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation

public struct UrlFrame: Frame {
    public enum UrlType: String, Codable {
        case commercialInformation               = "WCOM"
        case copyrightLegalInformation           = "WCOP"
        case officialAudioFileWebpage            = "WOAF"
        case officialArtistPerformerWebpage      = "WOAR"
        case officialAudioSourceWebpage          = "WOAS"
        case officialInternetRadioStationWebpage = "WORS"
        case payment                             = "WPAY"
        case officialPublisherWebpage            = "WPUB"
        
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
    
    public let type: UrlType
    public let urlString: String
    
    public var debugDescription: String {
        return "urlString=\(urlString)"
    }
    
    public var url: URL? {
        return URL(string: urlString)
    }
}

extension UrlFrame {
    public func frameData(version: MP3File.ID3Tag.Version) throws -> Data {
        switch version {
        case .v2_2:
            throw MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: self.type.rawValue)
        try fb.addString(str: self.urlString, encoding: .isoLatin1, includeEncodingByte: false, terminate: false)
        
        return try fb.data()
    }
}

extension UrlFrame {
    public static func parse(version: MP3File.ID3Tag.Version, data: Data) -> Frame? {
        guard let frameIdentifier = data.frameIdentifier(version: version) else {
            return nil
        }
        
        guard let urlType = UrlType(rawValue: frameIdentifier) else {
            return nil
        }
        
        return self.parse(type: urlType, version: version, data: data)
    }

    public static func parse(type: UrlType, version: MP3File.ID3Tag.Version, data: Data) -> Frame? {
        
        let offset = version.frameHeaderSizeInBytes
        
        let frameContent = data.subdata(in: offset ..< data.count)
        
        guard let str = String(data: frameContent, encoding: .isoLatin1) else {
            return nil
        }
        
        return UrlFrame(type: type, urlString: str)
    }
}
