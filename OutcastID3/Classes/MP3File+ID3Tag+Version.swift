//
//  TagVersion.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

extension MP3File.ID3Tag {
    public enum Version: UInt8 {
        case version2 = 2
        case version3 = 3
        case version4 = 4
        
        var encodingPositionInBytes: Int {
            switch self {
            case .version2: return 6
            case .version3: return 10
            case .version4: return 10
            }
        }
        
        var tagHeaderSizeInBytes: Int {
            return 10
        }
        
        var frameHeaderSizeInBytes: Int {
            switch self {
            case .version2: return 6
            case .version3: return 10
            case .version4: return 10
            }
        }

        var frameSizeOffsetInBytes: Int {
            switch self {
            case .version2: return 3
            case .version3: return 4
            case .version4: return 4
            }
        }
        
        var frameSizeByteCount: Int {
            return 4
        }
        
        var frameSizeMask: UInt32 {
            switch self {
            case .version2: return 0x00FFFFFF
            case .version3: return 0xFFFFFFFF
            case .version4: return 0xFFFFFFFF
            }
        }
        
        var frameIdentifierSizeInBytes: Int {
            switch self {
            case .version2: return 3
            case .version3: return 4
            case .version4: return 4
            }
        }
    }
}

