//
//  Data+String.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 25/11/18.
//

import Foundation

extension Data {
    public enum StringTerminator {
        case single
        case double
        
        var data: Data {
            switch self {
            case .single: return Data([ 0x0 ])
            case .double: return Data([ 0x0, 0x0 ])
            }
        }
    }
    
    func readString(offset: inout Int, encoding: String.Encoding, terminator: StringTerminator) -> String? {
        // unicode strings are terminated by \0\0, while latin terminated by \0
        
        var bytes: [UInt8] = []
        
        switch terminator {
        case .double:
            let startingOffset = offset
            
            while offset < self.count {
                let byte = self[offset]
                bytes.append(byte)
                offset += 1

                if byte == 0x0 && offset < self.count && self[offset] == 0x0 {
                    bytes.removeLast()
                    break
                }
            }
            
            offset += 1
            
        case .single:
            
            while offset < self.count {
                var byte: UInt8 = self[offset]

                if byte != 0x00 {
                    bytes.append(byte)
                    offset += 1
                } else {
                    break
                }
            }
            
            offset += 1
            
        }
        
        return String(bytes: bytes, encoding: encoding)
    }
}
