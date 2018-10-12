// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation

fileprivate extension String {
    var ascii: [UInt8] {
        return [UInt8](self.data(using: .ascii)!)
    }
}

/// Static class that contains utility functions for converting Base32 strings to and from bytes.
class Base32Encoder {
    // MARK: Methods
    private static let decodingTable :[UInt8] = {
        var table = [UInt8](repeating: 0xFF, count: 256)
        for code:UInt8 in 0..<26 {
            let lowerPosition = "a".ascii.first! + code
            let upperPosition = "A".ascii.first! + code
            table[Int(lowerPosition)] = code
            table[Int(upperPosition)] = code
        }
        for code:UInt8 in 0..<6 {
            let position = "2".ascii.first! + code
            table[Int(position)] = code + 26
        }

        table[Int("=".ascii.first!)] = 0
        return table
    }()

    /**
     * Converts a base32 string to a byte array.
     *
     * - parameter base32String: The input Base32 string.
     * - returns: The output byte array.
     * - throws: Nem2SdkSwiftError.illegalArgument if the string is malformed.
     */
    public static func bytes(from base32String: String) throws -> [UInt8] {
        let paddingAdjustment: [Int] = [0, 1, 1, 1, 2, 3, 3, 4];
        let encoded = base32String
                .replacingOccurrences(of: "=", with: "")
                .replacingOccurrences(of: " ", with: "")

        let encodedBytes = encoded.ascii
        let encodedLength = encodedBytes.count

        let encodedBlocks = (encodedLength + 7) >> 3;
        let expectedDataLength = encodedBlocks * 5;

        var decodedBytes = [UInt8](repeating: 0, count: expectedDataLength)
        var encodedBytesToProcess = encodedLength
        var encodedBaseIndex = 0
        var decodedBaseIndex = 0
        var encodedBlock = [UInt8](repeating: 0, count: 8)

        var encodedBlockIndex = 0
        while encodedBytesToProcess >= 1 {
            encodedBytesToProcess -= 1

            var c = encodedBytes[encodedBaseIndex]
            encodedBaseIndex += 1

            c = decodingTable[Int(c)]
            if c == 0xFF {
                throw Nem2SdkSwiftError.illegalArgument("\(encodedBytes[encodedBaseIndex-1]) cannot be decoded.")
            }

            encodedBlock[encodedBlockIndex] = c
            encodedBlockIndex += 1
            if encodedBlockIndex == 8 {
                let encodedByte1 = encodedBlock[0]
                let encodedByte2 = encodedBlock[1]
                let encodedByte3 = encodedBlock[2]
                let encodedByte4 = encodedBlock[3]
                let encodedByte5 = encodedBlock[4]
                let encodedByte6 = encodedBlock[5]
                let encodedByte7 = encodedBlock[6]
                let encodedByte8 = encodedBlock[7]
                decodedBytes[decodedBaseIndex] = ((encodedByte1 << 3) & 0xF8) | ((encodedByte2 >> 2) & 0x07)
                decodedBytes[decodedBaseIndex+1] = ((encodedByte2 << 6) & 0xC0) | ((encodedByte3 << 1) & 0x3E) | ((encodedByte4 >> 4) & 0x01)
                decodedBytes[decodedBaseIndex+2] = ((encodedByte4 << 4) & 0xF0) | ((encodedByte5 >> 1) & 0x0F)
                decodedBytes[decodedBaseIndex+3] = ((encodedByte5 << 7) & 0x80) | ((encodedByte6 << 2) & 0x7C) | ((encodedByte7 >> 3) & 0x03)
                decodedBytes[decodedBaseIndex+4] = ((encodedByte7 << 5) & 0xE0) | (encodedByte8 & 0x1F)
                decodedBaseIndex += 5
                encodedBlockIndex = 0
            }
        }

        if encodedBlockIndex > 0 {
            let encodedByte7 = encodedBlockIndex >= 7 ? encodedBlock[6] : 0
            let encodedByte6 = encodedBlockIndex >= 6 ? encodedBlock[5] : 0
            let encodedByte5 = encodedBlockIndex >= 5 ? encodedBlock[4] : 0
            let encodedByte4 = encodedBlockIndex >= 4 ? encodedBlock[3] : 0
            let encodedByte3 = encodedBlockIndex >= 3 ? encodedBlock[2] : 0
            let encodedByte2 = encodedBlockIndex >= 2 ? encodedBlock[1] : 0
            let encodedByte1 = encodedBlock[0]

            decodedBytes[decodedBaseIndex] = ((encodedByte1 << 3) & 0xF8) | ((encodedByte2 >> 2) & 0x07)
            decodedBytes[decodedBaseIndex+1] = ((encodedByte2 << 6) & 0xC0) | ((encodedByte3 << 1) & 0x3E) | ((encodedByte4 >> 4) & 0x01)
            decodedBytes[decodedBaseIndex+2] = ((encodedByte4 << 4) & 0xF0) | ((encodedByte5 >> 1) & 0x0F)
            decodedBytes[decodedBaseIndex+3] = ((encodedByte5 << 7) & 0x80) | ((encodedByte6 << 2) & 0x7C) | ((encodedByte7 >> 3) & 0x03)
            decodedBytes[decodedBaseIndex+4] = ((encodedByte7 << 5) & 0xE0)
        }
        decodedBaseIndex += paddingAdjustment[encodedBlockIndex];
        return Array(decodedBytes[0..<decodedBaseIndex])
    }
    /**
     * Converts a byte array to a Base32 string.
     *
     * - parameter bytes: The input byte array.
     * - returns: The output Base32 string.
     */
    public static func base32String(from bytes: [UInt8]) -> String {
        let encodingTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567".ascii
        let paddingTable = [0,6,4,3,1]

        //                     Table 3: The Base 32 Alphabet
        //
        // Value Encoding  Value Encoding  Value Encoding  Value Encoding
        //     0 A             9 J            18 S            27 3
        //     1 B            10 K            19 T            28 4
        //     2 C            11 L            20 U            29 5
        //     3 D            12 M            21 V            30 6
        //     4 E            13 N            22 W            31 7
        //     5 F            14 O            23 X
        //     6 G            15 P            24 Y         (pad) =
        //     7 H            16 Q            25 Z
        //     8 I            17 R            26 2

        let dataLength = bytes.count
        var encodedBlocks = dataLength / 5
        //if (encodedBlocks + 1) >= (UInt.max / 8) { return nil }// NSUInteger overflow check
        let padding = paddingTable[dataLength % 5]
        if padding > 0 {
            encodedBlocks += 1
        }

        let encodedLength = encodedBlocks * 8

        var encodingBytes = [UInt8](repeating: 0, count: encodedLength)

        var rawBytesToProcess = dataLength
        var rawBaseIndex = 0
        var encodingBaseIndex = 0

        while( rawBytesToProcess >= 5 ) {
            let rawByte1 = bytes[rawBaseIndex]
            let rawByte2 = bytes[rawBaseIndex+1]
            let rawByte3 = bytes[rawBaseIndex+2]
            let rawByte4 = bytes[rawBaseIndex+3]
            let rawByte5 = bytes[rawBaseIndex+4]

            encodingBytes[encodingBaseIndex] = encodingTable[Int((rawByte1 >> 3) & 0x1F)]
            encodingBytes[encodingBaseIndex+1] = encodingTable[Int(((rawByte1 << 2) & 0x1C) | ((rawByte2 >> 6) & 0x03)) ]
            encodingBytes[encodingBaseIndex+2] = encodingTable[Int((rawByte2 >> 1) & 0x1F)]
            encodingBytes[encodingBaseIndex+3] = encodingTable[Int(((rawByte2 << 4) & 0x10) | ((rawByte3 >> 4) & 0x0F))]
            encodingBytes[encodingBaseIndex+4] = encodingTable[Int(((rawByte3 << 1) & 0x1E) | ((rawByte4 >> 7) & 0x01))]
            encodingBytes[encodingBaseIndex+5] = encodingTable[Int((rawByte4 >> 2) & 0x1F)]
            encodingBytes[encodingBaseIndex+6] = encodingTable[Int(((rawByte4 << 3) & 0x18) | ((rawByte5 >> 5) & 0x07))]
            encodingBytes[encodingBaseIndex+7] = encodingTable[Int(rawByte5 & 0x1F)]

            rawBaseIndex += 5
            encodingBaseIndex += 8
            rawBytesToProcess -= 5
        }

        let rest = dataLength-rawBaseIndex
        if rest < 5 && rest > 0 {
            let rawByte4 = rest >= 4 ? bytes[rawBaseIndex+3] : 0
            let rawByte3 = rest >= 3 ? bytes[rawBaseIndex+2] : 0
            let rawByte2 = rest >= 2 ? bytes[rawBaseIndex+1] : 0
            let rawByte1 = bytes[rawBaseIndex]

            encodingBytes[encodingBaseIndex] = encodingTable[Int((rawByte1 >> 3) & 0x1F)]
            encodingBytes[encodingBaseIndex+1] = encodingTable[Int(((rawByte1 << 2) & 0x1C) | ((rawByte2 >> 6) & 0x03)) ]
            encodingBytes[encodingBaseIndex+2] = encodingTable[Int((rawByte2 >> 1) & 0x1F)]
            encodingBytes[encodingBaseIndex+3] = encodingTable[Int(((rawByte2 << 4) & 0x10) | ((rawByte3 >> 4) & 0x0F))]
            encodingBytes[encodingBaseIndex+4] = encodingTable[Int(((rawByte3 << 1) & 0x1E) | ((rawByte4 >> 7) & 0x01))]
            encodingBytes[encodingBaseIndex+5] = encodingTable[Int((rawByte4 >> 2) & 0x1F)]
            encodingBytes[encodingBaseIndex+6] = encodingTable[Int((rawByte4 << 3) & 0x18)]
        }
        // compute location from where to begin inserting padding, it may overwrite some bytes from the partial block encoding
        // if their value was 0 (cases 1-3).
        encodingBaseIndex = encodedLength - padding
        for i in 0..<padding {
            encodingBytes[encodingBaseIndex + i] = Array("=".utf8)[0]
        }

        return String(bytes: encodingBytes, encoding: .utf8)!

    }
}