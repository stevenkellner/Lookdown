//
//  Errors.swift
//  Lookdown
//
//  Created by Steven on 06.08.21.
//

import Foundation

extension Lookdown {
    
    /// Errors that can be thrown while initialization of Lookdown.
    public enum InitializationError: Error {
        
        /// Error thrown at initialization with json string that can't be encoded with utf-8.
        case invalidUTF8String
        
        /// Error thrown at initialization with json data that isn't a valid json object.
        case invalidJsonObject
    }
    
    /// Errors that can be thrown while decoding Lookdown JSON.
    public enum DecodingError: Error {
        
        /// Error thrown while getting value with a key from a value and not a dictionary.
        case valueAccessFromSingleValue
        
        /// Error thrown while getting value with a key from a dictionary that doesn't contain that key.
        case keyNotFoundInDictionary
        
        /// Error thrown while getting value with an index from a value that isn't an array.
        case valueNoArray
        
        /// Error thrown while getting value with an index from an array that doesn't contain that index.
        case invalidIndexInArray
        
        /// Error thrown while converting a value from an invalid type.
        case invalidTypeConversion
    }
}

extension Array {
    
    /// Adds a new element at the end of the returning array.
    /// - Parameter newElement: Element to add to array
    /// - Returns: Array with added element
    internal func appending(_ newElement: Element) -> [Element] {
        var list = self
        list.append(newElement)
        return list
    }
}

postfix operator |?
