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
        
        if let url = Bundle.main.url(forResource: "test", withExtension: "mp3") {
            do {
                let x = try MP3File(localUrl: url)

                let tag = try x.parseID3Tag()
                
                let version = tag.version
                
                for rawFrame in tag.rawFrames {
                    guard let frame = rawFrame.frame else {
                        continue
                    }
                    
                    switch frame {
                    case let f as StringFrame:
                        switch f.type {
                        case .albumTitle:
                            print("Album Title: \(f.str)")

                        default:
                            break
                        }

                    case let f as ChapterFrame:
                        break
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

