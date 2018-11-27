//
//  Frame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 27/11/18.
//

import Foundation

public protocol Frame: CustomDebugStringConvertible {
    static func parse(version: MP3File.ID3Tag.Version, data: Data) -> Frame?
    
    /// Used to build raw data that can be written to an MP3 file
    func frameData(version: MP3File.ID3Tag.Version) throws -> Data
}
