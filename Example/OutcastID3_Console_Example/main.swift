//
//  main.swift
//  OutcastID3_Console_Example
//
//  Created by Quentin Zervaas on 23/4/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

guard let url = Bundle.main.url(forResource: "test", withExtension: "mp3") else {
    print("Test MP3 not found")
    exit(1)
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
