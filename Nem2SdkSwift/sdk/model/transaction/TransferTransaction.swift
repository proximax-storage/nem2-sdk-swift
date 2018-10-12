// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

/// Transfer transaction.
public class TransferTransaction: Transaction {
    /// Address of the recipient.
    public let recipient: Address
    /// List of mosaic objects.
    public let mosaics: [Mosaic]
    /// Transaction message.
    public let message: Message?


    init(base: Transaction,
         recipient: Address,
         mosaics: [Mosaic],
         message: Message?) {

        self.recipient = recipient
        self.mosaics = mosaics
        self.message = message

        super.init(base: base)
    }

    /**
     * Create a transfer transaction object.
     *
     * - parameter recipient:   Recipient of the transaction.
     * - parameter mosaics:     Array of mosaics.
     * - parameter message:     Transaction message.
     * - parameter networkType: Network type.
     * - parameter deadline:    Deadline to include the transaction.(Optional. The default is 1 hour from now.)
     */
    public static func create(
            recipient: Address,
            mosaics: [Mosaic],
            message: Message? = nil,
            networkType: NetworkType,
            deadline: Deadline = Deadline(fromNow: 60 * 60)) -> TransferTransaction {
        let base = Transaction(type: .transfer, networkType: networkType, version: 3, deadline: deadline)
        return TransferTransaction(base: base, recipient: recipient, mosaics: mosaics, message: message)
    }

    override func getTransactionBodyBytes() -> [UInt8] {
        let recipientBytes = recipient.bytes

        // message
        let messageSize: UInt16
        let messageBytes: [UInt8]
        if let message = self.message {
            messageSize = UInt16(message.payload.count + 1)
            messageBytes = [message.type] + message.payload
        } else {
            messageSize = 0
            messageBytes = []
        }
        // mosaics
        let mosaicsBytes = mosaics.map { mosaic in mosaic.id.id.bytes + mosaic.amount.bytes }.reduce([]) { $0 + $1 }

        return recipientBytes +
                messageSize.bytes +
                UInt8(mosaics.count).bytes +
                messageBytes +
                mosaicsBytes
    }
}
