//
//  CodingPath.swift
//  Lookdown
//
//  Created by Steven on 06.08.21.
//

import Foundation

/// Protocol for coding path that contains a path from the raw data
/// and a method to get new lookdown for dynamic member and
/// index subscript.
public protocol CodingPathProtocol {
    
    /// Type of new lookdown for dynamic memeber and index subscript.
    associatedtype DynamicMemberLookdown
    
    /// Gets new lookdown for dynamic member and index subscript.
    /// - Parameters:
    ///    - component: String key or index of new coding path component.
    ///    - rawData: Raw data of Lookdown JSON
    /// - Returns: New lookdown with appended coding path component.
    func dynamicMemberLookdown(_ component: ThrowableCodingPathComponentProtocol, rawData: Any) -> DynamicMemberLookdown
}

/// Protocol for throwable coding path that contains a path with throwable
/// coding path components.
public protocol ThrowableCodingPathProtocol: CodingPathProtocol {
    
    /// Path with throwable coding path components.
    var path: [ThrowableCodingPathComponentProtocol] { get }
}

/// Protocol for optional coding path that contains a path with optional
/// coding path components.
public protocol OptionalCodingPathProtocol: CodingPathProtocol {
    
    /// Path with optional coding path components.
    var path: [OptionalCodingPathComponentProtocol] { get }
}

/// Protocol for optional coding path that contains a path with throwable
/// or optional coding path components.
public protocol OptionalThrowableCodingPathProtocol: CodingPathProtocol {
    
    /// Path with throwable or optional coding path components.
    var path: [OptionalThrowableCodingPathComponentProtocol] { get }
}

/// Protocol for coding path that contains a method to get new lookdown
/// for optional operator.
public protocol CodingPathWithOptionalProtocol {
    
    /// Type of new lookdown for optional operator.
    associatedtype OptionalOperatorLookdown
    
    /// Gets new lookdown for optional operator.
    /// - Parameter rawData: Raw data of Lookdown JSON.
    /// - Returns: New lookdown where last path component is optional.
    func optionalOperatorLookdown(rawData: Any) -> OptionalOperatorLookdown
}

/// Coding path with optional components and last one is throwable
public struct OptionalCodingPathLastThrowable: OptionalThrowableCodingPathProtocol, CodingPathWithOptionalProtocol {
    
    /// Optional path of this coding path
    private let optionalPath: [OptionalCodingPathComponentProtocol]
    
    /// Last component of this coding path
    private let lastComponent: ThrowableCodingPathComponentProtocol
    
    /// Initializes coding path with optional path and last component.
    /// - Parameters:
    ///   - optionalPath: Optional path of this coding path
    ///   - lastComponent: Last component of this coding path
    internal init(optionalPath: [OptionalCodingPathComponentProtocol], lastComponent: ThrowableCodingPathComponentProtocol) {
        self.optionalPath = optionalPath
        self.lastComponent = lastComponent
    }
    
    public var path: [OptionalThrowableCodingPathComponentProtocol] {
        (self.optionalPath as [OptionalThrowableCodingPathComponentProtocol]).appending(self.lastComponent)
    }
    
    public func dynamicMemberLookdown(_ component: ThrowableCodingPathComponentProtocol, rawData: Any) -> OptionalThrowableLookdown<OptionalThrowableCodingPathLastThrowable> {
        let path = OptionalThrowableCodingPathLastThrowable(optionalThrowablePath: self.path, lastComponent: component)
        return OptionalThrowableLookdown(rawData, path: path)
    }
    
    public func optionalOperatorLookdown(rawData: Any) -> OptionalLookdown<OptionalCodingPath> {
        let path = OptionalCodingPath(optionalPath: self.optionalPath.appending(self.lastComponent.optionalComponent))
        return OptionalLookdown(rawData, path: path)
    }
}

/// Coding path with optional components
public struct OptionalCodingPath: OptionalCodingPathProtocol {
    
    /// Optional path of this coding path
    private let optionalPath: [OptionalCodingPathComponentProtocol]
    
    /// Initializes coding path with optional path.
    /// - Parameter optionalPath: Optional path of this coding path
    internal init(optionalPath: [OptionalCodingPathComponentProtocol]) {
        self.optionalPath = optionalPath
    }
    
    public var path: [OptionalCodingPathComponentProtocol] {
        self.optionalPath
    }
    
    public func dynamicMemberLookdown(_ component: ThrowableCodingPathComponentProtocol, rawData: Any) -> OptionalThrowableLookdown<OptionalCodingPathLastThrowable> {
        let path = OptionalCodingPathLastThrowable(optionalPath: self.optionalPath, lastComponent: component)
        return OptionalThrowableLookdown(rawData, path: path)
    }
}

/// Coding path with throwable components
public struct ThrowableCodingPath: ThrowableCodingPathProtocol, CodingPathWithOptionalProtocol {
    
    /// Throwable path of this coding path
    private let throwablePath: [ThrowableCodingPathComponentProtocol]
    
    /// Initialiezes coding path with throwable path
    /// - Parameter throwablePath: Throwable path of this coding path
    internal init(throwablePath: [ThrowableCodingPathComponentProtocol]) {
        self.throwablePath = throwablePath
    }
    
    public var path: [ThrowableCodingPathComponentProtocol] {
        self.throwablePath
    }
    
    public func dynamicMemberLookdown(_ component: ThrowableCodingPathComponentProtocol, rawData: Any) -> ThrowableLookdown<ThrowableCodingPath> {
        let path = ThrowableCodingPath(throwablePath: self.throwablePath.appending(component))
        return ThrowableLookdown(rawData, path: path)
    }
    
    public func optionalOperatorLookdown(rawData: Any) -> OptionalThrowableLookdown<OptionalThrowableCodingPathLastOptional> {
        var throwablePath = self.throwablePath
        guard let lastComponent = throwablePath.popLast() else { fatalError() }
        let path = OptionalThrowableCodingPathLastOptional(optionalThrowablePath: throwablePath, lastComponent: lastComponent.optionalComponent)
        return OptionalThrowableLookdown(rawData, path: path)
    }
}

/// Coding path with optional and throwable components and last one is throwable
public struct OptionalThrowableCodingPathLastThrowable: OptionalThrowableCodingPathProtocol, CodingPathWithOptionalProtocol {
    
    /// Optional, throwable path of this coding path
    private let optionalThrowablePath: [OptionalThrowableCodingPathComponentProtocol]
    
    /// Last component of this coding path
    private let lastComponent: ThrowableCodingPathComponentProtocol
    
    /// Initialiezes coding path with optional, throwable path and last component
    /// - Parameters:
    ///   - optionalThrowablePath: Optional, throwable path of this coding path
    ///   - lastComponent: Last component of this coding path
    internal init(optionalThrowablePath: [OptionalThrowableCodingPathComponentProtocol], lastComponent: ThrowableCodingPathComponentProtocol) {
        self.optionalThrowablePath = optionalThrowablePath
        self.lastComponent = lastComponent
    }
    
    public var path: [OptionalThrowableCodingPathComponentProtocol] {
        self.optionalThrowablePath.appending(self.lastComponent)
    }
    
    public func dynamicMemberLookdown(_ component: ThrowableCodingPathComponentProtocol, rawData: Any) -> OptionalThrowableLookdown<OptionalThrowableCodingPathLastThrowable> {
        let path = OptionalThrowableCodingPathLastThrowable(optionalThrowablePath: self.optionalThrowablePath.appending(self.lastComponent), lastComponent: component)
        return OptionalThrowableLookdown(rawData, path: path)
    }
    
    public func optionalOperatorLookdown(rawData: Any) -> OptionalThrowableLookdown<OptionalThrowableCodingPathLastOptional> {
        let path = OptionalThrowableCodingPathLastOptional(optionalThrowablePath: self.optionalThrowablePath, lastComponent: self.lastComponent.optionalComponent)
        return OptionalThrowableLookdown(rawData, path: path)
    }
}

/// Coding path with optional and throwable components and last one is optional
public struct OptionalThrowableCodingPathLastOptional: OptionalThrowableCodingPathProtocol {
    
    /// Optional, throwable path of this coding path
    private let optionalThrowablePath: [OptionalThrowableCodingPathComponentProtocol]
    
    /// Last component of this coding path
    private let lastComponent: OptionalCodingPathComponentProtocol
    
    /// Initialiezes coding path with optional, throwable path and last component
    /// - Parameters:
    ///   - optionalThrowablePath: Optional, throwable path of this coding path
    ///   - lastComponent: Last component of this coding path
    internal init(optionalThrowablePath: [OptionalThrowableCodingPathComponentProtocol], lastComponent: OptionalCodingPathComponentProtocol) {
        self.optionalThrowablePath = optionalThrowablePath
        self.lastComponent = lastComponent
    }
    
    public var path: [OptionalThrowableCodingPathComponentProtocol] {
        self.optionalThrowablePath.appending(self.lastComponent)
    }
    
    public func dynamicMemberLookdown(_ component: ThrowableCodingPathComponentProtocol, rawData: Any) -> OptionalThrowableLookdown<OptionalThrowableCodingPathLastThrowable> {
        let path = OptionalThrowableCodingPathLastThrowable(optionalThrowablePath: self.optionalThrowablePath.appending(self.lastComponent), lastComponent: component)
        return OptionalThrowableLookdown(rawData, path: path)
    }
}

/// Coding path with only one throwable component
public struct CodingPathOneThrowable: ThrowableCodingPathProtocol, CodingPathWithOptionalProtocol {
    
    /// Single component of this coding path
    private let component: ThrowableCodingPathComponentProtocol
    
    /// Initializes coding path with single component
    /// - Parameter component: Single component of this coding path
    internal init(component: ThrowableCodingPathComponentProtocol) {
        self.component = component
    }
    
    public var path: [ThrowableCodingPathComponentProtocol] {
        [self.component]
    }
    
    public func dynamicMemberLookdown(_ component: ThrowableCodingPathComponentProtocol, rawData: Any) -> ThrowableLookdown<ThrowableCodingPath> {
        let path = ThrowableCodingPath(throwablePath: [self.component, component])
        return ThrowableLookdown(rawData, path: path)
    }
    
    public func optionalOperatorLookdown(rawData: Any) -> OptionalLookdown<OptionalCodingPath> {
        let path = OptionalCodingPath(optionalPath: [self.component.optionalComponent])
        return OptionalLookdown(rawData, path: path)
    }
}
