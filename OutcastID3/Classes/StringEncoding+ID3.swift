//
//  StringEncoding+ID3.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 25/11/18.
//

import Foundation

extension String.Encoding {
    static func fromEncodingByte(byte: UInt8, version: MP3File.ID3Tag.Version) -> String.Encoding {
        
        let encoding: String.Encoding
        
        switch byte {
        case 0x01: encoding = .utf16
        case 0x03: encoding = .utf8
        default: encoding = .isoLatin1
        }
        
        switch (version, encoding) {
        case (.v2_4, .utf8): return encoding
        case (_, .utf8): return .isoLatin1
        default: return encoding
        }
        
    }
}

