// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

import Foundation


enum AnyObjectDictionary: Codable {
    case integer(Int64)
    case double(Double)
    case string(String)
    case boolean(Bool)
    case array([AnyObjectDictionary])
    case object([String: AnyObjectDictionary])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let bool = try? container.decode(Bool.self) {
            self = .boolean(bool)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let int = try? container.decode(Int64.self) {
            self = .integer(int)
        } else if let number = try? container.decode(Double.self) {
            self = .double(number)
        } else if let array = try? container.decode([AnyObjectDictionary].self) {
            self = .array(array)
        } else if let dict = try? container.decode([String: AnyObjectDictionary].self) {
            self = .object(dict)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Could not decode data into a JSON-compatible value")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let int):
            try container.encode(int)
        case .double(let number):
            try container.encode(number)
        case .string(let string):
            try container.encode(string)
        case .boolean(let bool):
            try container.encode(bool)
        case .array(let jsonArray):
            try container.encode(jsonArray)
        case .object(let jsonObject):
            try container.encode(jsonObject)
        }
    }
}

/*
struct AnyCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) { self.stringValue = stringValue }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {
    func decode(_ type: [Any].Type, forKey key: K) throws -> [Any] {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: [Any].Type, forKey key: K) throws -> [Any]? {
        guard contains(key) else { return .none }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: [String:Any].Type, forKey key: K) throws -> [String:Any] {
        let container = try nestedContainer(keyedBy: AnyCodingKeys.self, forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: [String:Any].Type, forKey key: K) throws -> [String:Any]? {
        guard contains(key) else { return .none }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: [String:Any].Type) throws -> [String:Any] {
        var dictionary = [String:Any]()
        
        allKeys.forEach { key in
            if let value = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? decode(Int64.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? decode([String:Any].self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = value
            }
        }
        
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var array = [Any]()
        
        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let value = try? decode(Int64.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode([String:Any].self) {
                array.append(value)
            } else if let value = try? decode([Any].self) {
                array.append(value)
            }
        }
        
        return array
    }
    
    mutating func decode(_ type: [String:Any].Type) throws -> [String:Any] {
        let nestedContainer = try self.nestedContainer(keyedBy: AnyCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

struct AnyObjectDictionary: Codable {
    let items: [String:Any]
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKeys.self)
        items = try container.decode([String:Any].self)
    }
    
    func encode(to encoder: Encoder) throws {
        return
    }
}
*/
