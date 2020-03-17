//
//  FrameBuilder.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 27/11/18.
//

import Foundation

public class FrameBuilder {

    private let frameIdentifier: String
    private var content: Data = Data()

    public init(frameIdentifier: String) {
        self.frameIdentifier = frameIdentifier
    }
    
    public func data() throws -> Data {
        guard var ret = self.frameIdentifier.data(using: .isoLatin1) else {
            throw OutcastID3.MP3File.WriteError.stringEncodingError
        }
        
        let frameSize = UInt32(self.content.count)

        ret.append(frameSize.bigEndian.toData)
        
        // TODO: Write correct flags
        ret.append(contentsOf: [ 0x0, 0x0 ])
        ret.append(self.content)
        
        return ret
    }
    
    public func append(byte: UInt8) {
        self.content.append(byte)
    }
    
    public func append(data: Data) {
        self.content.append(data)
    }
    
    public func addStringEncodingByte(encoding: String.Encoding) {
        self.append(byte: encoding.encodingByte)
    }
    
    public func addString(str: String, encoding: String.Encoding, includeEncodingByte: Bool, terminator: Data.StringTerminator?) throws {
        guard let strData = str.data(using: encoding) else {
            throw OutcastID3.MP3File.WriteError.stringEncodingError
        }
        
        if includeEncodingByte {
            self.addStringEncodingByte(encoding: encoding)
        }
        
        self.content.append(strData)
        
        if let terminator = terminator {
            self.content.append(terminator.data)
        }
    }
}

extension UInt32 {
    var toData: Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
}

extension UInt16 {
    var toData: Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
}
