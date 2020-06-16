//
//  Frame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 27/11/18.
//

import Foundation

public protocol OutcastID3TagFrame: CustomDebugStringConvertible {
    static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame?
    
    /// Used to build raw data that can be written to an MP3 file
    func frameData(version: OutcastID3.TagVersion) throws -> Data
}
