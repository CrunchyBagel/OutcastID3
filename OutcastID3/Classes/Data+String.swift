//
//  Data+String.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 25/11/18.
//

import Foundation

extension Data {
    enum StringTerminator {
        case single
        case double
    }
    
    func readString(offset: inout Int, encoding: String.Encoding, terminator: StringTerminator) -> String? {
        // unicode strings are terminated by \0\0, while latin terminated by \0
        
        var bytes: [UInt8] = []
        
        switch terminator {
        case .double:
            let startingOffset = offset
            
            while offset < self.count {
                let byte = self[offset]
                
                if byte == 0x0 && offset > startingOffset {
                    if self[offset - 1] == 0x0 {
                        bytes.removeLast()
                        break
                    }
                }
                
                bytes.append(byte)
                offset += 1
            }
            
            offset += 1
            
        case .single:
            var byte: UInt8 = self[offset]
            
            while byte != 0x00 {
                bytes.append(byte)
                offset += 1
                byte = self[offset]
            }
            
            offset += 1
            
        }
        
        return String(bytes: bytes, encoding: encoding)
    }
}
