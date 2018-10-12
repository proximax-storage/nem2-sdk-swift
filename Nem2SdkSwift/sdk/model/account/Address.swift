// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.


import Foundation

/// The address structure describes an address with its network.
public struct Address: Equatable {
    private static let NUM_CHECKSUM_BYTES = 4
    private let address: String

    // MARK: Properties
    /// Network type
    public let networkType: NetworkType

    /// The address in plain format ex: SB3KUBHATFCPV7UZQLWAQ2EUR6SIHBSBEOEDDDF3.
    public var plain: String {
        return self.address
    }

    /// The address in pretty format ex: SB3KUB-HATFCP-V7UZQL-WAQ2EU-R6SIHB-SBEOED-DDF3.
    public var pretty: String {
        let matcher = try! NSRegularExpression(pattern: ".{1,6}")
        return matcher.matches(in: self.address, range: NSRange(location: 0, length: self.address.count)).map {
            (self.address as NSString).substring(with: $0.range)
        }.joined(separator: "-")
    }

    //  Address bytes before encoded with Base32
    let bytes: [UInt8]


    // MARK: Methods
    /**
     * Constructor
     *
     * - parameter address: Address in plain format
     * - parameter networkType: Network type
     * - throws: Nem2SdkSwiftError.illegalArgument if the address is invalid length or doesn't match the network.
     */
    public init(address: String, networkType: NetworkType) throws {
        self.address = address
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: " ", with: "")
                .uppercased()
        self.networkType = networkType

        guard let addressNetwork = self.address.first else {
            throw Nem2SdkSwiftError.illegalArgument("Address must not be empty.")
        }

        guard String(addressNetwork) == networkType.initialCharacterOfAddress else {
            throw Nem2SdkSwiftError
                    .illegalArgument("\(networkType.description) Address start with \(networkType.initialCharacterOfAddress)")
        }

        guard let bytes = try? Base32Encoder.bytes(from: self.address) else {
            throw Nem2SdkSwiftError
                    .illegalArgument("Address must be base 32 encoded.")
        }
        self.bytes = bytes
    }

    /**
     * Creates an Address from a given raw address.
     *
     * - parameter rawAddress: Address string.
     * - throws: Nem2SdkSwiftError.illegalArgument if the address is invalid length or does't match any network.
     */
    public init(rawAddress: String) throws {
        guard let addressNetwork = rawAddress.first else {
            throw Nem2SdkSwiftError.illegalArgument("Address must not be empty.")
        }

        for networkType in NetworkType.allCases {
            if networkType.initialCharacterOfAddress == String(addressNetwork) {
                try self.init(address: rawAddress, networkType: networkType)
                return
            }
        }
        throw Nem2SdkSwiftError.illegalArgument("Address \(rawAddress) has unknown network initial character.")
    }

    /**
     * Creates an Address from a given base32 encoded address.
     *
     * - parameter encodedAddress: Base32 encoded address string.
     * - throws: Nem2SdkSwiftError.illegalArgument if the address is invalid length or does't match any network.
     */
    public init(encodedAddress: String) throws {
        try self.init(rawAddress: String(Base32Encoder.base32String(from: try HexEncoder.toBytes(encodedAddress))))
    }


    /**
     * Creates from public key hex string.
     *
     * - parameter publicKeyHexString: Public key hex string.
     * - parameter networkType: Network type
     * - throws: Nem2SdkSwiftError.illegalArgument if the public key is invalid length or malformed.
     */
    public init(publicKeyHexString: String, networkType: NetworkType) throws {
        let address = try Address.generateEncoded(version: networkType.rawValue, publicKeyHexString: publicKeyHexString)
        try self.init(address: address, networkType: networkType)
    }

    /**
     * Creates from public key.
     *
     * - parameter publicKey: Public key.
     * - parameter networkType: Network type
     */
    public init(publicKey: PublicKey, networkType: NetworkType) {
        let address = Address.generateEncoded(version: networkType.rawValue, publicKeyBytes: publicKey.bytes)
        try! self.init(address: address, networkType: networkType)
    }

    private static func generateEncoded(version: UInt8, publicKeyHexString: String) throws -> String {
        guard let publicKeyBytes = try? HexEncoder.toBytes(publicKeyHexString) else {
            throw Nem2SdkSwiftError.illegalArgument("public key is not valid")
        }

        return generateEncoded(version: version, publicKeyBytes: publicKeyBytes)
    }


    private static func generateEncoded(version: UInt8, publicKeyBytes: [UInt8]) -> String {
        // step 1: sha3 hash of the public key
        let sha3PublicKeyHash = Hashes.sha3_256(publicKeyBytes)

        // step 2: ripemd160 hash of (1)
        let ripemd160StepOneHash = Hashes.ripemd160(sha3PublicKeyHash)

        // step 3: add version byte in front of (2)
        let versionPrefixedRipemd160Hash = [version] + ripemd160StepOneHash

        // step 4: get the checksum of (3)
        let stepThreeChecksum = Array(Hashes.sha3_256(versionPrefixedRipemd160Hash)[0..<NUM_CHECKSUM_BYTES])

        // step 5: concatenate (3) and (4)
        let concatStepThreeAndStepSix = versionPrefixedRipemd160Hash + stepThreeChecksum

        // step 6: base32 encode (5)
        return Base32Encoder.base32String(from: concatStepThreeAndStepSix)
    }

    /// :nodoc:
    public static func ==(lhs: Address, rhs: Address) -> Bool {
        return lhs.address == rhs.address && lhs.networkType == rhs.networkType
    }
}
