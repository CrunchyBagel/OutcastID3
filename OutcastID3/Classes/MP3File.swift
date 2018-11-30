//
//  MP3File.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

public class OutcastID3 {
    public struct ID3Tag {
        public let version: TagVersion
        public let frames: [OutcastID3TagFrame]
        
        public init(version: TagVersion, frames: [OutcastID3TagFrame]) {
            self.version = version
            self.frames = frames
        }
    }

    public class MP3File {
        public struct TagProperties {
            public let tag: ID3Tag
            
            public let startingByteOffset: UInt64
            public let endingByteOffset: UInt64
        }

        let localUrl: URL

        public init(localUrl: URL) throws {
            self.localUrl = localUrl
        }
    }

    public struct Frame {}
}
