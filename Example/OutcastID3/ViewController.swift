//
//  ViewController.swift
//  OutcastID3
//
//  Created by HendX on 11/23/2018.
//  Copyright (c) 2018 HendX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = Bundle.main.url(forResource: "test", withExtension: "mp3") else {
            print("Test MP3 not found")
            return
        }
        
        do {
            print("BEGIN READ TEST")
            try TagExample.readTest(url: url)
        }
        catch {
            print("Read test error: \(error)")
        }
        
//        do {
//            print("BEGIN WRITE TEST")
//            try TagExample.writeTest(url: url)
//        }
//        catch {
//            print("Write test error: \(error)")
//        }
    }
}

