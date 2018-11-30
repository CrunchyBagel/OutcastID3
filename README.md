# OutcastID3

[![CI Status](https://img.shields.io/travis/HendX/OutcastID3.svg?style=flat)](https://travis-ci.org/HendX/OutcastID3)
[![Version](https://img.shields.io/cocoapods/v/OutcastID3.svg?style=flat)](https://cocoapods.org/pods/OutcastID3)
[![License](https://img.shields.io/cocoapods/l/OutcastID3.svg?style=flat)](https://cocoapods.org/pods/OutcastID3)
[![Platform](https://img.shields.io/cocoapods/p/OutcastID3.svg?style=flat)](https://cocoapods.org/pods/OutcastID3)

A lightweight Swift library for reading ID3 tags, including chapters.


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
let url = Bundle.main.url(forResource: "MyFile", withExtension: "mp3")!

do {
    let mp3 = try MP3File(localUrl: url)
    let tag = try x.readID3Tag()

    let version = tag.tag.version

    for frame in tag.tag.frames {
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
catch {

}
```

## Installation

OutcastID3 is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'OutcastID3'
```

## Author

Crunchy Bagel, hello@crunchybagel.com

## License

OutcastID3 is available under the MIT license. See the LICENSE file for more info.
