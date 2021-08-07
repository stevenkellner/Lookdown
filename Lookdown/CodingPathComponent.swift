//
//  CodingPathComponent.swift
//  Lookdown
//
//  Created by Steven on 06.08.21.
//

import Foundation

/// Protocol for coding path component that are optional or throws an error
public protocol OptionalThrowableCodingPathComponentProtocol {
    
    /// Gets new value from this coding path component, returns optional
    /// value and can throw an error
    /// - Parameter oldValue: Value to get new value from
    /// - Returns: New value from this coding path component
    func newValue(fromOld oldValue: Any) throws -> Any?
}

/// Protocol for coding component that throws an error
public protocol ThrowableCodingPathComponentProtocol: OptionalThrowableCodingPathComponentProtocol {
    
    /// Optional coding path component of this component
    var optionalComponent: OptionalCodingPathComponentProtocol { get }
    
    /// Gets new value from this coding path component,  can throw an error
    /// - Parameter oldValue: Value to get new value from
    /// - Returns: New value from this coding path component
    func newValue(from oldValue: Any) throws -> Any
}

extension OptionalThrowableCodingPathComponentProtocol where Self: ThrowableCodingPathComponentProtocol {
    internal func newValue(fromOld oldValue: Any) throws -> Any? {
        try self.newValue(from: oldValue)
    }
}

/// Protocol for coding path component that are optional
public protocol OptionalCodingPathComponentProtocol: OptionalThrowableCodingPathComponentProtocol {
    
    /// Gets new value from this coding path component, returns optional value
    /// - Parameter oldValue: Value to get new value from
    /// - Returns: New value from this coding path component
    func newValue(from oldValue: Any) -> Any?
}

extension OptionalThrowableCodingPathComponentProtocol where Self: OptionalCodingPathComponentProtocol {
    internal func newValue(fromOld oldValue: Any) throws -> Any? {
        self.newValue(from: oldValue)
    }
}

/// Coding path component with a string key
internal struct StringKeyCodingPathComponent: ThrowableCodingPathComponentProtocol {
    
    /// String key of this path component
    private let stringKey: String
    
    /// Initializes path component with a string key
    /// - Parameter stringKey: String key of the path component
    internal init(_ stringKey: String) {
        self.stringKey = stringKey
    }
    
    internal var optionalComponent: OptionalCodingPathComponentProtocol {
        OptionalStringKeyCodingPathComponent(self.stringKey)
    }
    
    internal func newValue(from oldValue: Any) throws -> Any {
        guard let dictionary = oldValue as? [String : Any?], let _value = dictionary[self.stringKey], let value = _value else {
            throw Lookdown.DecodingError.keyNotFoundInDictionary
        }
        return value
    }
}

/// Coding path component with a string key of optional value
internal struct OptionalStringKeyCodingPathComponent: OptionalCodingPathComponentProtocol {
    
    /// String key of this path component
    private let stringKey: String
    
    /// Initializes path component with a string key
    /// - Parameter stringKey: String key of the path component
    internal init(_ stringKey: String) {
        self.stringKey = stringKey
    }
    
    internal func newValue(from oldValue: Any) -> Any? {
        guard let dictionary = oldValue as? [String : Any?], let _value = dictionary[self.stringKey], let value = _value else { return nil }
        return value
    }
}

/// Coding path component with an index
internal struct IndexCodingPathComponent: ThrowableCodingPathComponentProtocol {
    
    /// Index of this path component
    private let index: Int
    
    /// Initializes path component with an index
    /// - Parameter index: Index of the path component
    init(_ index: Int) {
        self.index = index
    }
    
    internal var optionalComponent: OptionalCodingPathComponentProtocol {
        OptionalIndexCodingPathComponent(self.index)
    }
    
    internal func newValue(from oldValue: Any) throws -> Any {
        guard let array = oldValue as? [Any] else {
            throw Lookdown.DecodingError.valueNoArray
        }
        guard array.indices.contains(self.index) else {
            throw Lookdown.DecodingError.invalidIndexInArray
        }
        return array[self.index]
    }
}

/// Coding path component with an index of optional value
internal struct OptionalIndexCodingPathComponent: OptionalCodingPathComponentProtocol {
    
    /// Index of this path component
    private let index: Int
    
    /// Initializes path component with an index
    /// - Parameter index: Index of the path component
    internal init(_ index: Int) {
        self.index = index
    }
    
    internal func newValue(from oldValue: Any) -> Any? {
        guard let array = oldValue as? [Any], array.indices.contains(self.index) else { return nil }
        return array[self.index]
    }
}
