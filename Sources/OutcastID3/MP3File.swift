//
//  MP3File.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

/// Top-level namespace for the OutcastID3 library.
public class OutcastID3 {
    /// A parsed ID3 tag containing its version and frames.
    public struct ID3Tag {
        /// The ID3v2 version of this tag.
        public let version: TagVersion
        /// The frames contained in this tag.
        public let frames: [OutcastID3TagFrame]
        
        /// Creates an ID3 tag with the specified version and frames.
        /// - Parameters:
        ///   - version: The ID3v2 tag version.
        ///   - frames: The frames to include in the tag.
        public init(version: TagVersion, frames: [OutcastID3TagFrame]) {
            self.version = version
            self.frames = frames
        }
    }

    /// Represents an MP3 file on disk and provides reading and writing of ID3 tags.
    public class MP3File {
        /// The result of reading an ID3 tag, including its byte range within the file.
        public struct TagProperties {
            /// The parsed ID3 tag.
            public let tag: ID3Tag

            /// The byte offset where the tag begins in the file.
            public let startingByteOffset: UInt64
            /// The byte offset where the tag ends in the file.
            public let endingByteOffset: UInt64
        }

        let localUrl: URL

        /// Creates an MP3 file reference for the given local file URL.
        /// - Parameter localUrl: The file URL of the MP3 file on disk.
        public init(localUrl: URL) throws {
            self.localUrl = localUrl
        }
    }

    /// Namespace for all ID3 frame type implementations.
    public struct Frame {}
}

extension OutcastID3.Frame: Sendable {}
