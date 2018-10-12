// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation
import Nem2SdkSwift

class TestSettings {
    // NIS2 host address
    //static let host = "http://localhost:3000"
    static let url = URL(string: "http://192.168.10.9:3000")!
    static let nemesisSigner = "SC2O7KMJVJBWU6MLVPBNNIVJ7YDLKVGGZ6ZZVALL"

    static let testAddress = "SBOKJ2CSEI5BNEZPCBUIJXB5BT6MQ3DPYGBGW5EO"
    static let testPublicKey = "D13A7C3EEA5A3479CBCF029C39728AB33A569AF6CAAD06E16C9871B4C5685CB3"



    // signerA is cosigner of signerB
    static let signerAAddress = "SD7LAI-7F4M4J-JNZLOJ-LWKJX5-A7RVIA-SS5F2L-VXOU"
    // signerB is cosigner of signerC
    static let signerBAddress = "SBAVUG-5LAPBP-SPWSC6-DSY56N-PGURUY-QNJVZC-VWBJ"
    // signerC is cosigner of multisigD
    static let signerCAddress = "SCRGUD-XW3I6G-ENE335-G6VYE5-EO3RRJ-Q2PNZV-J7YI"
    // signerD is cosigner for nobody.
    static let signerDAddress = "SAV3CA-WZXSND-JWAE4C-BXLIPH-ZKPVAS-YBO4P7-QC74"

    // existing transaction hash
    static let transactionHash = "42F5AA8E5876CF746D78E209241F25C6C70F8595B808FC2F13DFA52C4BE6B673".toBytesFromHexString()!


    static let accountPrivateKey = "7DC9CB2015E7E180E86F6037E79EEF98F347056ADF89324A97858D7628433652"

    // multisig account
    static let multisigAddress = "SCVP43UXKXMPMWINL52RQIFG55YPEIPLXEXHR5FB"
    static let multisigPublicKey = "B5C9CDEA5A4858EAE6452B454308691028E017C0272228A5A1A4A9876BB29FFA"
    static let multisigPrivateKey = "AE8E76C7F1C75555E6FEC6F85494E98894DED157F0E75907B07F0A87A4B4821C"

    // need 10 xem over to use
    static let cosignatory1PrivateKey = "424373EEF79A50907BC6D45C419A2500FC78E311FC1E0741AB135BF7FD38EF84"

    static let cosignatory2PrivateKey = "EE315AA74661FC13F1AF61319437A8F38C6994757E07830CAD708E361CDB26DF"

}