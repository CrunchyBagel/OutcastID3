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
    
    func readString(offset: inout Int,
                    encoding: String.Encoding,
                    terminator: StringTerminator) -> String? {

        var bytes: [UInt8] = []

        switch terminator {
        case .double:
            let start = offset

            while offset < self.count {
                let byte = self[offset]

                if byte == 0x00, offset > start, self[offset - 1] == 0x00 {
                    if !bytes.isEmpty { bytes.removeLast() }
                    break
                }

                bytes.append(byte)
                offset += 1
            }

            if offset < self.count { offset += 1 }

        case .single:
            while offset < self.count {
                let byte = self[offset]
                if byte == 0x00 { break }
                bytes.append(byte)
                offset += 1
            }

            if offset < self.count { offset += 1 }
        }

        return String(bytes: bytes, encoding: encoding)
    }
}
