// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation
import Starscream
import RxSwift


/// WebSocket Listener
public class Listener {
    private let webSocket: WebSocket
    private let webSocketDelegate: WebSocketDelegateImpl
    private let messageSubject: PublishSubject<ListenerMessage>
    private let connectionSubject: PublishSubject<String>
    private let errorSubject: PublishSubject<Error>
    private var openCompletable: Completable?
    private let disposeBag = DisposeBag()

    var uid: String?

    // MARK: Methods
    /**
     * Creates WebSocket Listener.
     * - parameter url: Host url.
     */
    public init(url: URL) {
        self.webSocket = WebSocket(url: url.appendingPathComponent("ws"))
        self.connectionSubject = PublishSubject()
        self.messageSubject = PublishSubject()
        self.errorSubject = PublishSubject()
        self.webSocketDelegate = WebSocketDelegateImpl(
                connectionSubject: self.connectionSubject,
                messageSubject: self.messageSubject,
                errorSubject: self.errorSubject)

        self.webSocket.delegate = self.webSocketDelegate
        self.uid = nil
    }

    /**
     * Opens WebSocket connection.
     *
     * - returns: Completable that resolves when the WebSocket connection is opened
     */
    public func open() -> Completable {
        if self.uid != nil {
            return Completable.create { observer in
                observer(.completed)
                return Disposables.create()
            }
        }


        webSocket.connect()
        return Completable.create { observer in
            self.connectionSubject.subscribe(onNext: { uid in
                self.uid = uid
                observer(.completed)
            }).disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }


    /// Close webSocket connection
    public func close() {
        self.uid = nil
        self.webSocket.disconnect()
    }

    private func subscribeTo(channel: ListenerChannel, additionalPath: String? = nil) {
        guard let uid = self.uid else {
            return
        }
        let subscribeMessage = ListenerSubscribeMessage(
                uid: uid,
                subscribe: channel.rawValue + (additionalPath != nil ? "/" + additionalPath! : ""))

        let jsonEncoder = JSONEncoder()

        guard let encoded = try? jsonEncoder.encode(subscribeMessage),
              let encodedString = String(data: encoded, encoding: .utf8) else {
            return
        }

        self.webSocket.write(string: encodedString)
    }


    /**
     * Returns an observable stream of BlockInfo.
     * Each time a new Block is added into the blockchain,
     * it emits a new BlockInfo in the event stream.
     *
     * - returns: Observable stream of BlockInfo
     */
    public func newBlock() -> Observable<BlockInfo> {
        self.subscribeTo(channel: .block)
        return self.messageSubject.flatMap { message -> Observable<BlockInfo> in
            if case .block(let blockInfo) = message {
                return Observable.just(blockInfo)
            }
            return Observable.empty()
        }
    }

    /**
     * Returns an observable stream of Transaction for a specific address.
     * Each time a transaction is in confirmed state an it involves the address,
     * it emits a new Transaction in the event stream.
     *
     * - parameter address: Address we listen when a transaction is in confirmed state
     * - returns: Observable stream of Transaction with state confirmed
     */
    public func confirmed(address: Address) -> Observable<Transaction> {
        self.subscribeTo(channel: .confirmedAdded, additionalPath: address.plain)
        return self.messageSubject.flatMap { message -> Observable<Transaction> in
            if case .confirmedAdded(let transaction) = message {
                if transaction.isRelatedWith(address: address) {
                    return Observable.just(transaction)
                }
            }
            return Observable.empty()
        }
    }

    /**
     * Returns an observable stream of Transaction for a specific address.
     * Each time a transaction is in unconfirmed state an it involves the address,
     * it emits a new Transaction in the event stream.
     *
     * - parameter address: Address we listen when a transaction is in unconfirmed state
     * - returns: Observable stream of Transaction with state unconfirmed
     */
    public func unconfirmedAdded(address: Address) -> Observable<Transaction> {
        self.subscribeTo(channel: .unconfirmedAdded, additionalPath: address.plain)
        return self.messageSubject.flatMap { message -> Observable<Transaction> in
            if case .unconfirmedAdded(let transaction) = message {
                if transaction.isRelatedWith(address: address) {
                    return Observable.just(transaction)
                }
            }
            return Observable.empty()
        }
    }

    /**
     * Returns an observable stream of Transaction Hashes for specific address.
     * Each time a transaction with state unconfirmed changes its state,
     * it emits a new message with the transaction hash in the event stream.
     *
     * - parameter address: Address we listen when a transaction is removed from unconfirmed state
     * - returns: Observable stream of Strings with the transaction hash
     */
    public func unconfirmedRemoved(address: Address) -> Observable<[UInt8]> {
        self.subscribeTo(channel: .unconfirmedRemoved, additionalPath: address.plain)
        return self.messageSubject.flatMap { message -> Observable<[UInt8]> in
            if case .unconfirmedRemoved(let hash) = message {
                return Observable.just(hash)
            }
            return Observable.empty()
        }
    }

    /**
     * Return an observable of AggregateTransaction for specific address.
     * Each time an aggregate bonded transaction is announced,
     * it emits a new AggregateTransaction in the event stream.
     *
     * - parameter address: address we listen when a transaction with missing signatures state
     * - returns: Observable stream of AggregateTransaction with missing signatures state
     */
    public func aggregateBondedAdded(address: Address) -> Observable<AggregateTransaction> {
        self.subscribeTo(channel: .partialAdded, additionalPath: address.plain)
        return self.messageSubject.flatMap { message -> Observable<AggregateTransaction> in
            if case .partialAdded(let transaction) = message {
                if transaction.isRelatedWith(address: address) {
                    return Observable.just(transaction)
                }
            }
            return Observable.empty()
        }
    }

    /**
     * Returns an observable stream of Transaction Hashes for specific address.
     * Each time an aggregate bonded transaction is announced,
     * it emits a new message with the transaction hash in the event stream.
     *
     * - parameter address: Address we listen when a transaction is confirmed or rejected
     * - returns: Observable stream of Strings with the transaction hash
     */
    public func aggregateBondedRemoved(address: Address) -> Observable<[UInt8]> {
        self.subscribeTo(channel: .partialRemoved, additionalPath: address.plain)
        return self.messageSubject.flatMap { message -> Observable<[UInt8]> in
            if case .partialRemoved(let hash) = message {
                return Observable.just(hash)
            }
            return Observable.empty()
        }
    }

    /**
     * Returns an observable stream of {@link TransactionStatusError} for specific address.
     * Each time a transaction contains an error,
     * it emits a new message with the transaction status error in the event stream.
     *
     * - parameter address: Address we listen to be notified when some error happened
     * - returns: Observable stream of TransactionStatusError
     */
    public func status(address: Address) -> Observable<TransactionStatusError> {
        self.subscribeTo(channel: .status, additionalPath: address.plain)
        return self.messageSubject.flatMap { message -> Observable<TransactionStatusError> in
            if case .status(let transactionStatusError) = message {
                return Observable.just(transactionStatusError)
            }
            return Observable.empty()
        }
    }

    /**
     * Returns an observable stream of CosignatureSignedTransaction for specific address.
     * Each time a cosigner signs a transaction the address initialized,
     * it emits a new message with the cosignatory signed transaction in the even stream.
     *
     * - parameter address: Address we listen when a cosignatory is added to some transaction address sent
     * - returns: Observable stream of CosignatureSignedTransaction
     */
    public func cosignatureAdded(address: Address) -> Observable<CosignatureSignedTransaction> {
        self.subscribeTo(channel: .cosignature, additionalPath: address.plain)
        return self.messageSubject.flatMap { message -> Observable<CosignatureSignedTransaction> in
            if case .cosignature(let cosignature) = message {
                return Observable.just(cosignature)
            }
            return Observable.empty()
        }
    }

    /**
     * Returns an observable stream of Error.
     * - returns: Observable stream of Error.
     */
    public func error() -> Observable<Error> {
        return self.errorSubject
    }


    class WebSocketDelegateImpl: WebSocketDelegate {
        let connectionSubject: PublishSubject<String>
        let messageSubject: PublishSubject<ListenerMessage>
        let errorSubject: PublishSubject<Error>

        init(connectionSubject: PublishSubject<String>, messageSubject: PublishSubject<ListenerMessage>, errorSubject: PublishSubject<Error>) {
            self.connectionSubject = connectionSubject
            self.messageSubject = messageSubject
            self.errorSubject = errorSubject
        }

        public func websocketDidConnect(socket: WebSocketClient) {
        }

        public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        }

        public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
            do {
                try parseTextMessage(text: text)
            } catch let error {
                self.errorSubject.onNext(error)
            }
        }

        private func parseTextMessage(text: String) throws {
            let jsonDecoder = JSONDecoder()
            guard let rawData = text.data(using: .utf8) else {
                throw Nem2SdkSwiftError.parseError("Failed to encode text message as utf.")
            }

            if let uidDTO = try? jsonDecoder.decode(ListenerUIDDTO.self, from: rawData) {
                self.connectionSubject.onNext(uidDTO.uid)
            } else if let transactionDTO = try? jsonDecoder.decode(ListenerTransactionDTO.self, from: rawData) {
                self.messageSubject.onNext(try transactionDTO.toMessage(rawData: rawData))
            } else if let blockDTO = try? jsonDecoder.decode(ListenerBlockDTO.self, from: rawData) {
                self.messageSubject.onNext(try blockDTO.toMessage())
            } else if let statusDTO = try? jsonDecoder.decode(ListenerStatusDTO.self, from: rawData) {
                self.messageSubject.onNext(try statusDTO.toMessage())
            } else if let hashDTO = try? jsonDecoder.decode(ListenerHashDTO.self, from: rawData) {
                self.messageSubject.onNext(try hashDTO.toMessage())
            } else if let cosignatureDTO = try? jsonDecoder.decode(ListenerCosignatureDTO.self, from: rawData) {
                self.messageSubject.onNext(try cosignatureDTO.toMessage())
            } else {
                throw Nem2SdkSwiftError.parseError("Unknown text message: \(text)")
            }
        }

        public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        }
    }


    private struct ListenerUIDDTO: Codable {
        let uid: String
    }

    private struct ListenerTransactionDTO: Codable {
        let transaction: AnyObjectDictionary
        let meta: MetaData

        struct MetaData: Codable {
            let channelName: String
        }


        func toMessage(rawData: Data) throws -> ListenerMessage {
            guard let channel = ListenerChannel(rawValue: self.meta.channelName) else {
                throw Nem2SdkSwiftError.parseError("Failed to parse channel name of transaction.")
            }

            let jsonDecoder = JSONDecoder()
            let rawTransaction = try jsonDecoder.decode(AnyObjectDictionary.self, from: rawData)

            let transaction = try TransactionMapping.apply(rawTransaction)
            switch channel {
            case .unconfirmedAdded: return .unconfirmedAdded(transaction)
            case .confirmedAdded: return .confirmedAdded(transaction)
            case .partialAdded:
                if let aggregateTransaction = transaction as? AggregateTransaction {
                    return .partialAdded(aggregateTransaction)
                } else {
                    throw Nem2SdkSwiftError.parseError("Message channel \(self.meta.channelName) is for AggregateTransaction but the transaction is not AggregateTransaction.")

                }
            default:
                throw Nem2SdkSwiftError.parseError("Message channel \(self.meta.channelName) is not for transaction channel.")
            }
        }
    }

    private struct ListenerBlockDTO: Codable {
        let meta: MetaData
        let block: Inner

        struct MetaData: Codable {
            let hash: String
            let generationHash: String
        }
        struct Inner: Codable {
            let signature: String
            let signer: String
            let version: Int
            let type: Int
            let height: UInt64DTO
            let timestamp: UInt64DTO
            let difficulty: UInt64DTO
            let previousBlockHash: String
            let blockTransactionsHash: String
        }

        func toMessage() throws -> ListenerMessage {
            let versionAndNetwork = self.block.version
            let version = Int(versionAndNetwork & 0xFF)
            let networkValue = UInt8((versionAndNetwork >> 8) & 0xFF)
            guard let networkType = NetworkType(rawValue: networkValue) else {
                throw Nem2SdkSwiftError.parseError("Failed to parse network type of block")
            }

            let block = self.block

            return .block(
                    BlockInfo(
                            hash: self.meta.hash,
                            generationHash: self.meta.generationHash,
                            totalFee: nil,
                            numTransactions: nil,
                            signature: block.signature,
                            signer: try PublicAccount(publicKeyHexString: block.signer, networkType: networkType),
                            networkType: networkType,
                            version: version,
                            type: block.type,
                            height: block.height.uint64Value,
                            timestamp: block.timestamp.uint64Value,
                            difficulty: block.difficulty.uint64Value,
                            previousBlockHash: block.previousBlockHash,
                            blockTransactionHash: block.blockTransactionsHash)
            )
        }
    }

    private struct ListenerStatusDTO: Codable {
        let status: String
        let hash: String
        let deadline: UInt64DTO

        func toMessage() throws -> ListenerMessage {
            return .status(TransactionStatusError(
                    hash: try HexEncoder.toBytes(self.hash),
                    status: self.status,
                    deadline: Deadline(fromNemesis: TimeInterval(self.deadline.uint64Value) / 1000.0)
            ))
        }
    }

    private struct ListenerHashDTO: Codable {
        let meta: MetaData

        struct MetaData: Codable {
            let channelName: String
            let hash: String
        }

        func toMessage() throws -> ListenerMessage {
            guard let channel = ListenerChannel(rawValue: self.meta.channelName) else {
                throw Nem2SdkSwiftError.parseError("Failed to parse channel name of hash.")
            }
            switch channel {
            case .unconfirmedRemoved: return .unconfirmedRemoved(try HexEncoder.toBytes(self.meta.hash))
            case .partialRemoved: return .partialRemoved(try HexEncoder.toBytes(self.meta.hash))
            default:
                throw Nem2SdkSwiftError.parseError("Message channel \(self.meta.channelName) is not for hash channel.")
            }
        }
    }

    private struct ListenerCosignatureDTO: Codable {
        let parentHash: String
        let signature: String
        let signer: String

        func toMessage() throws -> ListenerMessage {
            return .cosignature(CosignatureSignedTransaction(
                    parentHash: try HexEncoder.toBytes(self.parentHash),
                    signature: try HexEncoder.toBytes(self.signature),
                    signer: try HexEncoder.toBytes(self.signer)
            ))
        }
    }

}



private extension Transaction {
    func isRelatedWith(address: Address) -> Bool {
        if isSignedByOrSentTo(address: address) {
            return true
        }

        if let aggregateTransaction = self as? AggregateTransaction {
            for cosignature in aggregateTransaction.cosignatures {
                if cosignature.signer.address == address  {
                    return true
                }
            }
            for innerTransaction in aggregateTransaction.innerTransactions {
                if innerTransaction.isSignedByOrSentTo(address: address)  {
                    return true
                }
            }
        }
        return false
    }

    func isSignedByOrSentTo(address: Address) -> Bool{
        if let transferTransaction = self as? TransferTransaction {
            if transferTransaction.recipient == address {
                return true
            }
        }
        return signer?.address == address
    }
}