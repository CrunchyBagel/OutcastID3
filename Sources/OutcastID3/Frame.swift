//
//  Frame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 27/11/18.
//

import Foundation

/// A protocol that all ID3 tag frame types conform to, providing parsing and serialization.
public protocol OutcastID3TagFrame: CustomDebugStringConvertible {
    /// Parses a frame from raw ID3 tag data.
    /// - Parameters:
    ///   - version: The ID3v2 tag version.
    ///   - data: The raw data for this frame, including the frame header.
    ///   - useSynchSafeFrameSize: Whether to interpret the frame size as synch-safe.
    /// - Returns: A parsed frame, or `nil` if the data does not match this frame type.
    static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame?

    /// Serializes this frame to raw data suitable for writing to an ID3 tag.
    /// - Parameter version: The ID3v2 tag version to encode for.
    /// - Returns: The serialized frame data, including the frame header.
    func frameData(version: OutcastID3.TagVersion) throws -> Data
}
