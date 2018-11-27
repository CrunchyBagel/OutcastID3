//
//  ViewController.swift
//  OutcastID3
//
//  Created by HendX on 11/23/2018.
//  Copyright (c) 2018 HendX. All rights reserved.
//

import UIKit
import OutcastID3

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let urls: [URL] = [
            Bundle.main.url(forResource: "test", withExtension: "mp3")!,
        ]
        
        for url in urls {
            print("=======================================")
            print(url.lastPathComponent)
            
            do {
                let x = try MP3File(localUrl: url)
                
                let tag = try x.readID3Tag()

                for frame in tag.frames {
                    switch frame {
                    case let s as StringFrame:
                        print("\(s.type.description): \(s.str)")
                        
                    case let u as UrlFrame:
                        print("\(u.type.description): \(u.urlString)")

                    case let comment as CommentFrame:
                        print("COMMENT: \(comment)")
                        
                    case let transcription as TranscriptionFrame:
                        print("TRANSCRIPTION: \(transcription)")
                        
                    case let picture as PictureFrame:
                        print("PICTURE: \(picture)")

                    case let f as ChapterFrame:
                        print("CHAPTER: \(f)")
                        
                    case let toc as TableOfContentsFrame:
                        print("TOC: \(toc)")
                        
                    case let rawFrame as RawFrame:
                        print("Unrecognised frame: \(String(describing: rawFrame.frameIdentifier))")

                    default:
                        break
                    }
                }
            }
            catch let e {
                print("Error: \(e)")
            }
        }
    }
}

