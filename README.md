# OutcastID3

[![CI Status](https://img.shields.io/travis/HendX/OutcastID3.svg?style=flat)](https://travis-ci.org/HendX/OutcastID3)
[![Version](https://img.shields.io/cocoapods/v/OutcastID3.svg?style=flat)](https://cocoapods.org/pods/OutcastID3)
[![License](https://img.shields.io/cocoapods/l/OutcastID3.svg?style=flat)](https://cocoapods.org/pods/OutcastID3)
[![Platform](https://img.shields.io/cocoapods/p/OutcastID3.svg?style=flat)](https://cocoapods.org/pods/OutcastID3)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
let url = Bundle.main.url(forResource: "MyFile", withExtension: "mp3")!

do {
    let mp3 = try MP3File(localUrl: url)
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
