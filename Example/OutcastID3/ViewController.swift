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
                
                let tag = try x.parseID3Tag()
                
                for rawFrame in tag.rawFrames {
                    guard let frame = rawFrame.frame else {
                        continue
                    }
                    
                    switch frame {
                    case let f as StringFrame:
                        print("\(f.type.description): \(f.str)")
                        
                    case let comment as CommentFrame:
                        print("COMMENT: \(comment)")
                        
                    case let transcription as TranscriptionFrame:
                        print("TRANSCRIPTION: \(transcription)")
                        
                    case let picture as PictureFrame:
                        print("PICTURE: \(picture)")

                    case let f as ChapterFrame:
                        print("CHAPTER: \(f)")

                    default:
                        break
                    }
                }
            }
            catch {
                
            }
        }
    }
}

