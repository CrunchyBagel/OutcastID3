//
//  FrameBuilder.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 27/11/18.
//

import UIKit

class FrameBuilder {

    private let frameIdentifier: String
    private var content: Data = Data()

    init(frameIdentifier: String) {
        self.frameIdentifier = frameIdentifier
    }
    
    func data() throws -> Data {
        guard var ret = self.frameIdentifier.data(using: .isoLatin1) else {
            throw MP3File.WriteError.stringEncodingError
        }
        
        // TODO: Finish implementing this
//        let frameSize = UInt32(0)
//
//        ret.append(frameSize.da)
        
        ret.append(self.content)
        
        return ret
    }
    
    /// Add a string in ISO-8859-1 without termination and without encoding byte
    
    func addString(str: String) throws {
        try self.addString(str: str, encoding: .isoLatin1, includeEncodingByte: false, terminate: false)
    }
    
    /// Add a string with encoding byte. Can optionally terminate if necessary
    
    func addEncodedString(str: String, encoding: String.Encoding, terminate: Bool) throws {
        try self.addString(str: str, encoding: encoding, includeEncodingByte: true, terminate: terminate)
    }
    
    private func addString(str: String, encoding: String.Encoding, includeEncodingByte: Bool, terminate: Bool) throws {
        guard let strData = str.data(using: encoding) else {
            throw MP3File.WriteError.stringEncodingError
        }
        
        if includeEncodingByte {
            self.content.append(contentsOf: [encoding.encodingByte])
        }
        
        self.content.append(strData)

        if terminate {
            switch encoding {
            case .utf8, .utf16:
                self.content.append(contentsOf: [0x0])
                self.content.append(contentsOf: [0x0])
            default:
                self.content.append(contentsOf: [0x0])
            }
        }
    }
}
