//
//  TagExample.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 23/4/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import OutcastID3

extension String: Error {}

class TagExample {
    class func readTest(url: URL) throws {
        
        print(url.lastPathComponent)
        
        let x = try OutcastID3.MP3File(localUrl: url)
        
        let tag = try x.readID3Tag()
        self.outputTag(tag: tag.tag)
    }
    
    class func writeTest(url: URL) throws {
        guard let baseDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw "Documents directory not found"
        }
        
        
        let x = try OutcastID3.MP3File(localUrl: url)
        
        let testUrl = baseDir.appendingPathComponent("writeTest.mp3")
        print("Output URL: \(testUrl.path)")

//        let originalTag = try x.readID3Tag().tag
        
        do {
            try FileManager.default.removeItem(at: testUrl)
        }
        catch {}
        
        let titleFrame = OutcastID3.Frame.StringFrame(
            type: .title,
            encoding: .utf8,
            str: "Tag Writer Test"
        )
        
        let commentFrame = OutcastID3.Frame.CommentFrame(
            encoding: .utf8, language: "eng",
            commentDescription: "description",
            comment: "Comment Test"
        )
        
        let transcriptionFrame = OutcastID3.Frame.TranscriptionFrame(
            encoding: .utf8, language: "eng",
            lyricsDescription: "description",
            lyrics: "Lyrics Test"
        )
        
        let frames: [OutcastID3TagFrame] = [
            titleFrame, commentFrame, transcriptionFrame
        ]
        
        let tag = OutcastID3.ID3Tag(
            version: .v2_4,
            frames: frames
        )
        
        //        print("Will save the following tag:")
        //        self.outputTag(tag: tag)
        
        let mp3File = try OutcastID3.MP3File(localUrl: url)
        try mp3File.writeID3Tag(tag: tag, outputUrl: testUrl)
        
//        let image = OutcastID3.Frame.PictureFrame.Picture.PictureImage(named: "your_image")
//
//        if let image = image {
//            let picture = OutcastID3.Frame.PictureFrame.Picture(image: image)
//
//            let pictureFrame = OutcastID3.Frame.PictureFrame(
//                encoding: .utf8,
//                mimeType: "image/png",
//                pictureType: .coverFront,
//                pictureDescription: "Front cover",
//                picture: picture
//            )
//        }
        
        
        let newMp3File = try OutcastID3.MP3File(localUrl: testUrl)
        let newTag = try newMp3File.readID3Tag()
        
        print("Reading tag from file:")
        self.outputTag(tag: newTag.tag)
    }
    
    class func outputTag(tag: OutcastID3.ID3Tag) {
        for frame in tag.frames {
            switch frame {
            case let s as OutcastID3.Frame.StringFrame:
                print("\(s.type.description): \(s)")
                
            case let u as OutcastID3.Frame.UrlFrame:
                print("\(u.type.description): \(u)")
                
            case let comment as OutcastID3.Frame.CommentFrame:
                print("Comment: \(comment)")
                
            case let transcription as OutcastID3.Frame.TranscriptionFrame:
                print("Transcription: \(transcription)")
                
            case let picture as OutcastID3.Frame.PictureFrame:
                print("Picture: \(picture)")
                
            case let f as OutcastID3.Frame.ChapterFrame:
                print("Chapter: \(f)")
                
            case let toc as OutcastID3.Frame.TableOfContentsFrame:
                print("TOC: \(toc)")
                
            case let rawFrame as OutcastID3.Frame.RawFrame:
                print("Unrecognised frame: \(String(describing: rawFrame.frameIdentifier))")
                
            default:
                break
            }
        }
    }

}
