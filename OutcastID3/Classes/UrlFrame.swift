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
        
        
        var description: String {
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

    static func parse(type: UrlType, version: MP3File.ID3Tag.Version, data: Data) -> UrlFrame? {
        
        let offset = version.frameHeaderSizeInBytes
        
        let frameContent = data.subdata(in: offset ..< data.count)
        
        guard let str = String(data: frameContent, encoding: .isoLatin1) else {
            return nil
        }
        
        return UrlFrame(type: type, urlString: str)
    }
}
