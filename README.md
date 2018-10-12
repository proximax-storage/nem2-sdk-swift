
# nem2-sdk for Swift 4

The nem2-sdk for Swift 4, available for mobile applications on iOS, to work with the NEM2 (a.k.a Catapult).

## Requirements

* iOS 9.0 or higher
* Swift 4 or higher

## Sample Project

Sample project are in Nem2SdkSwiftDemo directory.

## Installation

### Cocoa Pods
Not yet.

### Carthage
1. Insert github "proximax-storage/nem2-sdk-swift" to your Cartfile.

2. Run carthage update.

3. Add "Nem2SdkSwift.framework" to Linked Frameworks and Libraries  
    3-1. Select your application project in the Project navigator.  
    3-2. Click on the + button under the "Linked Frameworks and Libraries" section in General tab.  
    3-3. Select Nem2SwiftSdk.framework in Carthage/Build/iOS

4. Add Run Script in Build Phases  
    Build Phases -> Click "+" -> New Run Script Phase
    * Shell: /bin/sh
    * Script: /usr/local/bin/carthage copy-frameworks
    * Input Files: The following frameworks in Carthage/Build/iOS
        * Alamofire.framework
        * CryptoSwift.framework
        * Nem2SdkSwift.framework
        * RxSwift.framework
        * Starscream.framework

### Manual 

1. Clone this repository with submodules using "--recursive" switch.

    ```
    $ git clone --recursive https://github.com/proximax-storage/nem2-sdk-swift.git
    ```

2. Run carthage to download depending libraries.
    ```
    $ cd nem2-sdk-swift
    $ carthage update --platform ios
    ```
3. Add Nem2SwiftSdk.xcodeproj to your application project.  
    Right click on Navigator in Xcode, select "Add Files to ..." and select Nem2SwiftSdk.xcodeproj.

4. Add Nem2SwiftSdk.framework.  
    4-1. Select your application project in the Project navigator.  
    4-2. Click on the + button under the "Embedded Binaries" section in General tab.  
    4-3. Select Nem2SwiftSdk.framework
    
5. Add depeneded frameworks.  
    Add the following frameworks in "nem2-sdk-swift/Carthage/Build/iOS" directory to "Embedded Binaries"
    * RxSwift.framework
    
    If you don't check "Copy items if needed", add "nem2-sdk-swift/Carthage/Build/iOS" directory to "Framework Search Paths" of your application.

## How to use

### Account Generation

`Account` generates a NEM account. Network version is required.

```swift
let account = Account(networkType: .mijinTest)
```

If you have private key already, retrieve the account from the key.

```swift
let account = Account(privateKeyHexString: privateKey, network: .mijinTest)
```

### Sending XEM or Mosaics

First, create `TransferTransaction` object.

```swift
let transaction = TransferTransaction.create(
    recipient: try Address(rawAddress: "SC7A4H-7CYCSH-4CP4XI-ZS4G2G-CDZ7JP-PR5FRG-2VBU"),
    mosaics: [XEM.of(xemAmount: 10)],
    networkType: .mijinTest)
```
In this example, a sender sends 10 XEM to "SC7A4H-7CYCSH-4CP4XI-ZS4G2G-CDZ7JP-PR5FRG-2VBU" .

Next, sign the transaction with the sender account.

```swift
let signedTransaction = account.sign(transaction: transaction)
```

Then send the transaction with `TransactionHttp`.

```swift
import RxSwift
...

let transactionHttp = TransactionHttp(url: URL(string:"http://localhost:3000")!)
transactionHttp.announce(signedTransaction: signedTransaction).subscribe(
    onSuccess: { announceResult in
        ...
    },
    onError: { error in
        ...
    }).disposed(by: disposeBag)
```

The response is `Single` of RxSwift.

### Monitoring Transactions

`Listener` monitors block generations and the transactions you are insterested in.

First, create `Listener` instance and call `open`
```swift
let listener = Listener(url: URL(string:"http://localhost:3000")!)

listener.open().subscribe(
    onCompleted: {
       ...
    },
    onError: { error in
       ...
    }).disposed(by: disposeBag)
```
The response of `open` is `Completable` of RxSwift.

After `onCompleted` is notified, call `confirmed` or a function corresponding to the item you want to monitor.
```swift
listener.confirmed(address: address)
    .subscribe(onNext: { transaction in
         ...
    }).disposed(by: disposeBag)
```

The response of `confirmed` is Observable.
Each time a transaction is confirmed, `onNext` is notified.

## Other NEM2 APIs

You can use [REST API](https://nemtech.github.io/api.html) of NEM2 with AccountHttp, BlockchainHttp, MosaicHttp, NamespaceHttp, NetworkHttp and TransactionHttp.

See [REST API](https://nemtech.github.io/api.html) reference for detail.

## API Reference

You can see API Reference of Nem2SdkSwift in nem2-sdk-swift/docs.
Open nem2-sdk-swift/docs/index.html with your browser.

## Core Contributors ##

 + [@ryuta46](https://github.com/ryuta46) 
 + [@brambear](https://github.com/alvin-reyes)
 
## Contribution ##
We'd love to get more people involved in the project. Please feel free to raise any issues or PR and we'll review your contribution.

Copyright (c) 2018 ProximaX Limited
