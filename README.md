# StickerFaceSDK

<!-- [![CI Status](https://img.shields.io/travis/Xaker69/StickerFace.svg?style=flat)](https://travis-ci.org/Xaker69/StickerFace) -->
[![Version](https://img.shields.io/cocoapods/v/StickerFaceSDK.svg?style=flat)](https://cocoapods.org/pods/StickerFaceSDK)
[![License](https://img.shields.io/cocoapods/l/StickerFaceSDK.svg?style=flat)](https://cocoapods.org/pods/StickerFaceSDK)
[![Platform](https://img.shields.io/cocoapods/p/StickerFaceSDK.svg?style=flat)](https://cocoapods.org/pods/StickerFaceSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate StickerFaceSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'StickerFaceSDK'
```

## Using StickerFaceSDK

### Open StickerFace module

For open StickerFace module in new view controller:

```swift
StickerFace.shared.openStickerFace()
```

You can present module however you want. You can get root navigation controller like this: 

```swift
let navigationController = StickerFace.shared.getRootNavigationController()
```

Xaker69, max.xaker41@mail.ru

## License

StickerFace is released under the MIT license. [See LICENSE](https://github.com/startfellows/StickerFaceSDK/blob/master/LICENSE) for details.
