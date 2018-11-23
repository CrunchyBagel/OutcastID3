//
//  StringFrame.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

public struct StringFrame: Frame {
    public enum StringType {
        case title
        case description
        case comment
        case albumTitle
        case leadArtist
        case band
        case conductor
        case interpretedBy
        case publisher
        
        var description: String {
            switch self {
                
            case .title:
                return "Title"
            case .description:
                return "Description"
            case .comment:
                return "Comment"
            case .albumTitle:
                return "Album Title"
            case .leadArtist:
                return "Lead Artist"
            case .band:
                return "Band"
            case .conductor:
                return "Conductor"
            case .interpretedBy:
                return "Interpreted By"
            case .publisher:
                return "Publisher"
            }
        }
    }
    
    public let type: StringType
    public let str: String
    
    public var debugDescription: String {
        return "str=\(str)"
    }
}
