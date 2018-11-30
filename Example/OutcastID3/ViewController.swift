//
//  ViewController.swift
//  OutcastID3
//
//  Created by HendX on 11/23/2018.
//  Copyright (c) 2018 HendX. All rights reserved.
//

import UIKit
import OutcastID3

extension String: Error {}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = Bundle.main.url(forResource: "test", withExtension: "mp3") else {
            print("Test MP3 not found")
            return
        }
        
        do {
            print("BEGIN READ TEST")
            try self.readTest(url: url)
        }
        catch {
            print("Read test error: \(error)")
        }
        
        do {
            print("BEGIN WRITE TEST")
            try self.writeTest(url: url)
        }
        catch {
            print("Write test error: \(error)")
        }
    }
    
    func readTest(url: URL) throws {
        
        print(url.lastPathComponent)
        
        let x = try OutcastID3.MP3File(localUrl: url)
        
        let tag = try x.readID3Tag()
        self.outputTag(tag: tag.tag)
    }
    
    func writeTest(url: URL) throws {
        guard let baseDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw "Documents directory not found"
        }
        
        
        let x = try OutcastID3.MP3File(localUrl: url)
        
        let originalTag = try x.readID3Tag().tag

        
        let testUrl = baseDir.appendingPathComponent("writeTest.mp3")
        print("Output URL: \(testUrl.path)")
        
        do {
            try FileManager.default.removeItem(at: testUrl)
        }
        catch {}
        
        let frames: [OutcastID3TagFrame] = [
            OutcastID3.Frame.StringFrame(type: .title, encoding: .utf8, str: "Tag Writer Test")
        ]
        
        let tag = OutcastID3.ID3Tag(
            version: .v2_4,
            frames: frames
        )
        
//        print("Will save the following tag:")
//        self.outputTag(tag: tag)

        let mp3File = try OutcastID3.MP3File(localUrl: url)
        try mp3File.writeID3Tag(tag: originalTag, outputUrl: testUrl)
        
        let newMp3File = try OutcastID3.MP3File(localUrl: testUrl)
        let newTag = try newMp3File.readID3Tag()
        
        print("Reading tag from file:")
        self.outputTag(tag: newTag.tag)
    }

    func outputTag(tag: OutcastID3.ID3Tag) {
        for frame in tag.frames {
            switch frame {
            case let s as OutcastID3.Frame.StringFrame:
                print("\(s.type.description): \(s.str)")
                
            case let u as OutcastID3.Frame.UrlFrame:
                print("\(u.type.description): \(u.urlString)")

            case let comment as OutcastID3.Frame.CommentFrame:
                print("COMMENT: \(comment)")
                
            case let transcription as OutcastID3.Frame.TranscriptionFrame:
                print("TRANSCRIPTION: \(transcription)")
                
            case let picture as OutcastID3.Frame.PictureFrame:
                print("PICTURE: \(picture)")

            case let f as OutcastID3.Frame.ChapterFrame:
                print("CHAPTER: \(f)")
                
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

