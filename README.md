# Synaps verify

[![Swift Version][swift-image]][swift-url]
[![Build Status][travis-image]][travis-url]
[![License][license-image]][license-url]
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SynapsVerify.svg)](https://img.shields.io/cocoapods/v/SynapsVerify.svg)
[![Platform](https://img.shields.io/cocoapods/p/SynapsVerify.svg?style=flat)](http://cocoapods.org/pods/SynapsVerify)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

**Synaps is an all-in-one compliance platform**. It offers a simple, fast and secure way to meet compliance requirements at scale.

[Visit Synaps.io](https://synaps.io) | [Read the Synaps documentation](https://docs.synaps.io)

![enter image description here](https://storage.googleapis.com/synaps-docs-media/synaps-verify.png)

## Installation

### CocoaPods:

```ruby
pod 'SynapsVerify'
```

### Carthage:
```
github "synaps-io/ios-verify"
```
### Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/synaps-io/ios-verify", from: "0.0.1")
]
```

## Usage
```swift
import SynapsVerify
```
### SwiftUI
```swift
...
@State private var sessionId = ""
var body: some View {
    ...
    VerifyView(
        sessionId: self.$sessionId,
        lang: .french,
    )
    ...
```


### StoryBoard


#### How to setup it
The library allows you to use all the features of standard View with a lot of new cool features


First of all, drag & drop a new View inside your view controller in storyboard.

Then set the View class to `VerifyUiView` and link your view to your variable of the same type in your ViewController


#### How to launch it

`Swift`
```swift
import UIKit
import SynapsVerify

class VerifyViewController : UIViewController {
    @IBOutlet weak var verifyView: VerifyUiView!

    var sessionId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifyView.startSession(sessionId: sessionId, lang: .french)
    }
}
```

You are free to use `VerifyUiView` without StoryBoard

First of all, you should set the session id. Session Id can be referred as a customer verification session. [More info](https://help.synaps.io/manager-1/sessions)

#### Parameters list

| Parameter name          | Parameter type                                                                                           | Default | Required | Description                                                                   |
| ------------------ | --------------------------------------------------------------------------------------------------- | ------- | -------- | ----------------------------------------------------------------------------- |
| `sessionId`        | `string`                                                                                            | `''`    | Y        | Session can be referred as a customer verification session. [More info](https://help.synaps.io/manager-1/sessions)                                       |
| `lang`      | `VerifyLang`                                                                       | `.english`  | N        | You can set a predefined language for your user. Synaps already take advantage of browser language to display the relevant language to the end-user but if your user has set up a language option to your website, you can definitely pass it as an option.|
| `tier`      | `int`                                                                       | `null`  | N        | Tier is a simply way to divide your workflow into small pieces. It is very useful when you offer different features based on the verification level of your customer.  [More info](https://help.synaps.io/manager-1/apps/individual/tiers)                           |

### Configuration

Avant de lancer une session Verify. Le projet de votre application a besoin de quelque configuration.

#### NFC

The application must declare the use of the NFC chip, and must have NFC [entilement](https://developer.apple.com/documentation/bundleresources/entitlements) : 
```xml
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>TAG</string>
</array>
```

The Info.plist file must contain the field  `NFCReaderUsageDescription`

Your application's Info.plist file must contain the application IDs needed to scan the documents. 
```xml
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>A0000002471001</string>
    <string>A0000002472001</string>
    <string>E80704007F00070302</string>
    <string>A000000167455349474E</string>
    <string>A0000002480100</string>
    <string>A0000002480200</string>
    <string>A0000002480300</string>
    <string>A00000045645444C2D3031</string>
    <string>D2760000850101</string>
    <string>00000000000000</string>
</array>
```

More informations here : https://developer.apple.com/documentation/corenfc/nfciso7816tag

#### Camera

The Info.plist file may contain the field  `NSCameraUsageDescription`

To be able to take photos and analyze identification documents, the right to use the camera is required and must be claimed before building the Verify view (swiftui or UIKit). The Verify view will fire a `warning` if the rights are not acquired when the view is built.

```swift
AVCaptureDevice.requestAccess(
    for: .video,
    completionHandler: { accessGranted in
        ...
    }
)
```

### Listner

Now you are ready to listen Verify event by using a callback

`Swift UI`
```swift
VerifyView(
    ...
)
.onReady {
    ...
}
.onFinished {
    ...
}
```
`UIKit`

```swift
verifyView.onReady {
    ...
}
verifyView.onFinished {
    ...
}
```

#### Listener list

| Parameter name          | Parameter type                                                                                           | Default | Required | Description                                                                   |
| ------------------ | --------------------------------------------------------------------------------------------------- | ------- | -------- | ----------------------------------------------------------------------------- |
| `onReady`             | `() => Void`                                                                                           | `null` | No        | Event listener called when the page is fully loaded                                       |
| `onFinished`   | `() => Void`                                                                                           | `null` | No        | Event listener called when the user finished verification                     |


## Meta

[@synaps](https://twitter.com/synaps_id)

[https://github.com/synaps-hub/ios-verify](https://github.com/synaps-hub/ios-verify)

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-Apache2.0-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics

