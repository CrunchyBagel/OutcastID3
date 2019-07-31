//
//  TagVersion.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

extension OutcastID3 {
    public enum TagVersion: UInt8, Codable {
        case v2_2 = 2
        case v2_3 = 3
        case v2_4 = 4
        
        var encodingPositionInBytes: Int {
            switch self {
            case .v2_2: return 6
            case .v2_3: return 10
            case .v2_4: return 10
            }
        }
        
        var tagHeaderSizeInBytes: Int {
            return 10
        }
        
        var frameHeaderSizeInBytes: Int {
            switch self {
            case .v2_2: return 6
            case .v2_3: return 10
            case .v2_4: return 10
            }
        }

        var frameSizeOffsetInBytes: Int {
            switch self {
            case .v2_2: return 3
            case .v2_3: return 4
            case .v2_4: return 4
            }
        }
        
        var frameSizeByteCount: Int {
            return 4
        }
        
        var frameSizeMask: UInt32 {
            switch self {
            case .v2_2: return 0x00ffffff
            case .v2_3: return 0xffffffff
            case .v2_4: return 0xffffffff
            }
        }
        
        var frameIdentifierSizeInBytes: Int {
            switch self {
            case .v2_2: return 3
            case .v2_3: return 4
            case .v2_4: return 4
            }
        }
        
        func stringTerminator(encoding: String.Encoding) -> Data.StringTerminator {
            switch (self, encoding) {
            case (_, .utf16): return .double
            case (.v2_2, .utf8): return .double
            case (.v2_3, .utf8): return .double
            default: return .single
            }
        }
    }
}

