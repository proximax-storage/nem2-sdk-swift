// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import UIKit
import Nem2SdkSwift
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var textAddress: UILabel!
    @IBOutlet weak var textMessage: UITextView!
    
    var account: Account!
    
    static let url = URL(string: "http://192.168.10.9:3000")!

    let accountHttp = AccountHttp(url: ViewController.url)
    let transactionHttp = TransactionHttp(url: ViewController.url)
    let listener = Listener(url: ViewController.url)
    let disposeBag = DisposeBag()
    
    //let privateKey: String? = nil
    let privateKey: String? = "7DC9CB2015E7E180E86F6037E79EEF98F347056ADF89324A97858D7628433652"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        account = setupAccount()!

        listener.open()
            .subscribeOn(ConcurrentMainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: {
                self.listener.confirmed(address: self.account.address)
                    .subscribeOn(ConcurrentMainScheduler.instance)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { transaction in
                        self.showMessage("transaction \(transaction.transactionInfo!.hash!.hexString) confirmed")
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        textAddress.text = account.address.pretty
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTouchedAccountInfo(_ sender: Any) {
        fetchAccountInfo()
    }
    
    @IBAction func onTouchedSendXem(_ sender: Any) {
        let alert = UIAlertController(title: "Send XEM", message: "Input Address and Micro NEM", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.keyboardType = .asciiCapable
            textField.placeholder = "Receiver Address"
        }
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Micro NEM"
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self](action:UIAlertAction!) -> Void in
            guard let weakSelf = self else {
                return
            }
            let addressField = alert.textFields![0] as UITextField
            let microXemField = alert.textFields![1] as UITextField
            guard let address = addressField.text,
                let microXemText = microXemField.text,
                let microXem = Int(microXemText) else {
                    print("Failed to analyze input")
                    return
            }
            weakSelf.textMessage.text = ""
            do {
                try weakSelf.sendXem(address, UInt64(microXem))
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func setupAccount() -> Account? {
        if let privateKey = self.privateKey {
            return try? Account(privateKeyHexString: privateKey, networkType: .mijinTest)
        } else {
            return Account(networkType: .mijinTest)
        }
    }
    
    private func clearMessage() {
        textMessage.text = ""
    }
    
    private func showMessage(_ message: String) {
        textMessage.text.append(message + "\n")
    }
    
    private func fetchAccountInfo() {
        clearMessage()
        
        accountHttp.getAccountInfo(address: account.address)
            .subscribeOn(ConcurrentMainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { (result: AccountInfo) in
                    if let xem = result.mosaics.first(where: { mosaic in mosaic.id == XEM.mosaicId }) {
                        self.showMessage("balance: \(xem.amount) micro xem")
                    }
            },
                onError: { error in
                    self.showMessage(error.localizedDescription)
            }
            ).disposed(by: disposeBag)
    }
    
    
    private func sendXem(_ recipientAddress: String, _ microXem: UInt64) throws {
        clearMessage()
        // Create transfer transaction
        let transaction = TransferTransaction.create(
            recipient: try Address(address: recipientAddress, networkType: .mijinTest),
            mosaics: [XEM.of(microXemAmount: microXem)],
            message: PlainMessage.empty,
            networkType: .mijinTest)
        
        // Sign the transaction
        let signedTransaction = account.sign(transaction: transaction)
        
        // Send
        transactionHttp.announce(signedTransaction: signedTransaction)
            .subscribeOn(ConcurrentMainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { (result: TransactionAnnounceResponse) in
                    self.showMessage(result.message)
                    self.showTransactionStatus(signedTransaction.hash)
            },
                onError: { error in
                    self.showMessage(error.localizedDescription)
            }
            ).disposed(by: disposeBag)
    }
    
    private func showTransactionStatus(_ hash: [UInt8]) {
        // get transaction status and print
        transactionHttp.getTransactionStatus(hash: hash)
            .subscribeOn(ConcurrentMainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { (status: TransactionStatus) in
                    self.showMessage(status.status)
            },
                onError: { error in
                    // retry
                    self.showTransactionStatus(hash)
            }
            ).disposed(by: disposeBag)

    }
}


