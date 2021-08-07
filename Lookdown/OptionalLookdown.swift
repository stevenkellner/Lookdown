//
//  OptionalLookdown.swift
//  Lookdown
//
//  Created by Steven on 06.08.21.
//

import Foundation

// MARK: Lookdown declaration

/// Lookdown that contains optional values
@dynamicMemberLookup
public struct OptionalLookdown<CodingPath> where CodingPath: OptionalCodingPathProtocol {
    
    /// Stores the raw data of Lookdown JSON.
    private let rawData: Any
    
    /// Contains the coding path from the root to the previous step.
    private let codingPath: CodingPath
    
    /// Initializes Lookdown with a value of  type `[String : Any?]`,  a single value of type `Any`.
    /// - Parameters:
    ///    - value: Value of Lookdown.
    ///    - codingPath: Coding path from the root to the previous step.
    internal init(_ value: Any, path codingPath: CodingPath) {
        self.rawData = value
        self.codingPath = codingPath
    }
    
    // MARK: Access properties of Lookdown

    /// Access property of Lookdown with specified key.
    /// - Parameter key: Key of the property to access.
    /// - Returns: Lookdown with accessed property.
    public subscript(dynamicMember key: String) -> CodingPath.DynamicMemberLookdown {
        self.codingPath.dynamicMemberLookdown(StringKeyCodingPathComponent(key), rawData: self.rawData)
    }
    
    /// Access property of Lookdown with specified index if Lookdown is an array.
    /// - Parameter index: Index of the property to access.
    /// - Returns: Lookdown with accessed property.
    public subscript(_ index: Int) -> CodingPath.DynamicMemberLookdown {
        self.codingPath.dynamicMemberLookdown(IndexCodingPathComponent(index), rawData: self.rawData)
    }
}

extension OptionalLookdown where CodingPath: CodingPathWithOptionalProtocol {
    
    /// Makes last component optional
    /// - Parameter lhs: Lookdown to make last component optional
    /// - Returns: Optional Lookdown
    public static postfix func |?(lhs: OptionalLookdown) -> CodingPath.OptionalOperatorLookdown {
        lhs.codingPath.optionalOperatorLookdown(rawData: lhs.rawData)
    }
}

// MARK: Convert Lookdown property to given type

extension OptionalLookdown {
    
    /// Get current value from raw data and coding path
    private var currentValue: Any? {
        self.codingPath.path.reduce(self.rawData as Any?) { value, component in
            guard let value = value else { return nil }
            return component.newValue(from: value)
        }
    }
    
    /// Convert Lookdown property to specified type or throws an error if property can't be converted.
    /// - Parameter type: Type to convert property to.
    /// - Returns: Converted property.
    public func convertToType<T>(_ type: T.Type) -> T? {
        self.currentValue as? T
    }
    
    /// Lookdown property as a String or throws an error if the property cannot be converted
    /// to String or if there is no dynamic property with given name.
    @inlinable public var toString: String? {
        self.convertToType(String.self)
    }
    
    /// Lookdown property as a Double or throws an error if the property cannot be converted
    /// to Double or if there is no dynamic property with given name.
    @inlinable public var toDouble: Double? {
        self.convertToType(Double.self)
    }
    
    /// Lookdown property as a Int or throws an error if the property cannot be converted
    /// to Int or if there is no dynamic property with given name.
    @inlinable public var toInt: Int? {
        self.convertToType(Int.self)
    }
    
    /// Lookdown property as a Int32 or throws an error if the property cannot be converted
    /// to Int32 or if there is no dynamic property with given name.
    @inlinable public var toInt32: Int32? {
        self.convertToType(Int32.self)
    }
    
    /// Lookdown property as a Int64 or throws an error if the property cannot be converted
    /// to Int64 or if there is no dynamic property with given name.
    @inlinable public var toInt64: Int64? {
        self.convertToType(Int64.self)
    }
    
    /// Lookdown property as a Bool or throws an error if the property cannot be converted
    /// to Bool or if there is no dynamic property with given name.
    @inlinable public var toBool: Bool? {
        self.convertToType(Bool.self)
    }
    
    /// Lookdown property as a Array or throws an error if the property cannot be converted
    /// to Array or if there is no dynamic property with given name.
    ///
    /// Type of the element is also Lookdown as there can be more JSON nested.
    public var toArray: [Lookdown]? {
        self.convertToType([Any].self)?.map { Lookdown(value: $0) }
    }
    
    /// Lookdown property as a Dictionary or throws an error if the property cannot be converted
    /// to Dictionary or if there is no dynamic property with given name.
    ///
    /// Type of the value is also Lookdown as there can be more JSON nested.
    public var toDictionary: [String : Lookdown]? {
        self.convertToType([String : Any?].self)?.compactMapValues { Lookdown(value: $0) }
    }
    
    /// Decodes property to given type or throws an error if the property cannot be decoded
    /// to given type or if there is no dynamic property with given name.
    /// - Parameters:
    ///   - type: Type to decode to.
    ///   - decoder: Custom JSON Decoder.
    /// - Returns: Decoded Property.
    public func decode<T>(_ type: T.Type, decoder: JSONDecoder? = nil) -> T? where T: Decodable {
        let decoder = decoder ?? JSONDecoder()
        guard let dictionary = self.toDictionary,
              JSONSerialization.isValidJSONObject(dictionary),
              let data = try? JSONSerialization.data(withJSONObject: dictionary),
              let value = try? decoder.decode(type, from: data) else {
                  return nil
              }
        return value
    }
}

// MARK: Initialize Types with Lookdown property

extension String {
    
    /// Initialized String with Lookdown property or throws an error if the property cannot be converted
    /// to String or if there is no dynamic property with given name.
    /// - Parameter lookdown: Lookdown with property to convert from.
    @inlinable public init?<CodingPath>(lookdown: OptionalLookdown<CodingPath>) where CodingPath: OptionalCodingPathProtocol {
        guard let value = lookdown.toString else { return nil }
        self = value
    }
}

extension Double {
    
    /// Initialized Double with Lookdown property or throws an error if the property cannot be converted
    /// to DoubleDouble or if there is no dynamic property with given name.
    /// - Parameter lookdown: Lookdown with property to convert from.
    @inlinable public init?<CodingPath>(lookdown: OptionalLookdown<CodingPath>) where CodingPath: OptionalCodingPathProtocol {
        guard let value = lookdown.toDouble else { return nil }
        self = value
    }
}

extension Int {
    
    /// Initialized Int with Lookdown property or throws an error if the property cannot be converted
    /// to Int or if there is no dynamic property with given name.
    /// - Parameter lookdown: Lookdown with property to convert from.
    @inlinable public init?<CodingPath>(lookdown: OptionalLookdown<CodingPath>) where CodingPath: OptionalCodingPathProtocol {
        guard let value = lookdown.toInt else { return nil }
        self = value
    }
}

extension Int32 {
    
    /// Initialized Int32 with Lookdown property or throws an error if the property cannot be converted
    /// to Int32 or if there is no dynamic property with given name.
    /// - Parameter lookdown: Lookdown with property to convert from.
    @inlinable public init?<CodingPath>(lookdown: OptionalLookdown<CodingPath>) where CodingPath: OptionalCodingPathProtocol {
        guard let value = lookdown.toInt32 else { return nil }
        self = value
    }
}

extension Int64 {
    
    /// Initialized Int64 with Lookdown property or throws an error if the property cannot be converted
    /// to Int64 or if there is no dynamic property with given name.
    /// - Parameter lookdown: Lookdown with property to convert from.
    @inlinable public init?<CodingPath>(lookdown: OptionalLookdown<CodingPath>) where CodingPath: OptionalCodingPathProtocol {
        guard let value = lookdown.toInt64 else { return nil }
        self = value
    }
}

extension Bool {
    
    /// Initialized Bool with Lookdown property or throws an error if the property cannot be converted
    /// to Bool or if there is no dynamic property with given name.
    /// - Parameter lookdown: Lookdown with property to convert from.
    @inlinable public init?<CodingPath>(lookdown: OptionalLookdown<CodingPath>) where CodingPath: OptionalCodingPathProtocol {
        guard let value = lookdown.toBool else { return nil }
        self = value
    }
}

extension Array where Element == Lookdown {
    
    /// Initialized Array with Lookdown property or throws an error if the property cannot be converted
    /// to Array or if there is no dynamic property with given name.
    ///
    /// Type of the value is also Lookdown as there can be more JSON nested.
    /// - Parameter lookdown: Lookdown with property to convert from.
    @inlinable public init?<CodingPath>(lookdown: OptionalLookdown<CodingPath>) where CodingPath: OptionalCodingPathProtocol {
        guard let value = lookdown.toArray else { return nil }
        self = value
    }
}

extension Dictionary where Key == String, Value == Lookdown {
    
    /// Initialized Dictionary with Lookdown property or throws an error if the property cannot be converted
    /// to Dictionary or if there is no dynamic property with given name.
    ///
    /// Type of the value is also Lookdown as there can be more JSON nested.
    /// - Parameter lookdown: Lookdown with property to convert from.
    @inlinable public init?<CodingPath>(lookdown: OptionalLookdown<CodingPath>) where CodingPath: OptionalCodingPathProtocol {
        guard let value = lookdown.toDictionary else { return nil }
        self = value
    }
}

extension Decodable {
    
    /// Initialized with Lookdown property or throws an error if the property cannot be decoded
    /// or if there is no dynamic property with given name.
    /// - Parameters:
    ///   - lookdown: Lookdown with property to decode from.
    ///   - decoder: Custom JSON Decoder.
    @inlinable public init?<CodingPath>(lookdown: OptionalLookdown<CodingPath>, decoder: JSONDecoder? = nil) where CodingPath: OptionalCodingPathProtocol {
        guard let value = lookdown.decode(Self.self, decoder: decoder) else { return nil }
        self = value
    }
}
