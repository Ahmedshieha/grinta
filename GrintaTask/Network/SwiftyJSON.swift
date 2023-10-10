//  SwiftyJSON.swift
//  Captain One Driver
//
//  Created by Mohamed Akl on 19/06/2022.
//  Copyright © 2022 Mohamed Akl. All rights reserved.
//


import Foundation

// MARK: - Error
// swiftlint:disable line_length
public enum SwiftyJSONError: Int, Swift.Error {
    case unsupportedType = 999
    case indexOutOfBounds = 900
    case elementTooDeep = 902
    case wrongType = 901
    case notExist = 500
    case invalidJSON = 490
}

extension SwiftyJSONError: CustomNSError {
    
    /// return the error domain of SwiftyJSONError
    public static var errorDomain: String { return "com.swiftyjson.SwiftyJSON" }
    
    /// return the error code of SwiftyJSONError
    public var errorCode: Int { return self.rawValue }
    
    /// return the userInfo of SwiftyJSONError
    public var errorUserInfo: [String: Any] {
        switch self {
            case .unsupportedType:
                return [NSLocalizedDescriptionKey: "It is an unsupported type."]
            case .indexOutOfBounds:
                return [NSLocalizedDescriptionKey: "Array Index is out of bounds."]
            case .wrongType:
                return [NSLocalizedDescriptionKey: "Couldn't merge, because the JSONs differ in type on top level."]
            case .notExist:
                return [NSLocalizedDescriptionKey: "Dictionary key does not exist."]
            case .invalidJSON:
                return [NSLocalizedDescriptionKey: "SwiftyJSON is invalid."]
            case .elementTooDeep:
                return [NSLocalizedDescriptionKey: "Element too deep. Increase maxObjectDepth and make sure there is no reference loop."]
        }
    }
}

// MARK: - SwiftyJSON Type

/**
 SwiftyJSON's type definitions.
 
 See http://www.SwiftyJSON.org
 */
public enum Type: Int {
    case number
    case string
    case bool
    case array
    case dictionary
    case null
    case unknown
}

// MARK: - SwiftyJSON Base

public struct SwiftyJSON {
    
    /**
     Creates a SwiftyJSON using the data.
     
     - parameter data: The NSData used to convert to SwiftyJSON.Top level object in data is an NSArray or NSDictionary
     - parameter opt: The SwiftyJSON serialization reading options. `[]` by default.
     
     - returns: The created SwiftyJSON
     */
    public init(data: Data, options opt: JSONSerialization.ReadingOptions = []) throws {
        let object: Any = try JSONSerialization.jsonObject(with: data, options: opt)
        self.init(jsonObject: object)
    }
    
    /**
     Creates a SwiftyJSON object
     - note: this does not parse a `String` into SwiftyJSON, instead use `init(parseJSON: String)`
     
     - parameter object: the object
     
     - returns: the created SwiftyJSON object
     */
    public init(_ object: Any) {
        switch object {
            case let object as Data:
                do {
                    try self.init(data: object)
                } catch {
                    self.init(jsonObject: NSNull())
                }
            default:
                self.init(jsonObject: object)
        }
    }
    
    /**
     Parses the SwiftyJSON string into a SwiftyJSON object
     
     - parameter SwiftyJSON: the SwiftyJSON string
     
     - returns: the created SwiftyJSON object
     */
    public init(parseJSON jsonString: String) {
        if let data = jsonString.data(using: .utf8) {
            self.init(data)
        } else {
            self.init(NSNull())
        }
    }
    
    /**
     Creates a SwiftyJSON using the object.
     
     - parameter jsonObject:  The object must have the following properties: All objects are NSString/String, NSNumber/Int/Float/Double/Bool, NSArray/Array, NSDictionary/Dictionary, or NSNull; All dictionary keys are NSStrings/String; NSNumbers are not NaN or infinity.
     
     - returns: The created SwiftyJSON
     */
    fileprivate init(jsonObject: Any) {
        object = jsonObject
    }
    
    /**
     Merges another SwiftyJSON into this SwiftyJSON, whereas primitive values which are not present in this SwiftyJSON are getting added,
     present values getting overwritten, array values getting appended and nested JSONs getting merged the same way.
     
     - parameter other: The SwiftyJSON which gets merged into this SwiftyJSON
     
     - throws `ErrorWrongType` if the other JSONs differs in type on the top level.
     */
    public mutating func merge(with other: SwiftyJSON) throws {
        try self.merge(with: other, typecheck: true)
    }
    
    /**
     Merges another SwiftyJSON into this SwiftyJSON and returns a new SwiftyJSON, whereas primitive values which are not present in this SwiftyJSON are getting added,
     present values getting overwritten, array values getting appended and nested JSONS getting merged the same way.
     
     - parameter other: The SwiftyJSON which gets merged into this SwiftyJSON
     
     - throws `ErrorWrongType` if the other JSONs differs in type on the top level.
     
     - returns: New merged SwiftyJSON
     */
    public func merged(with other: SwiftyJSON) throws -> SwiftyJSON {
        var merged = self
        try merged.merge(with: other, typecheck: true)
        return merged
    }
    
    /**
     Private woker function which does the actual merging
     Typecheck is set to true for the first recursion level to prevent total override of the source SwiftyJSON
     */
    fileprivate mutating func merge(with other: SwiftyJSON, typecheck: Bool) throws {
        if type == other.type {
            switch type {
                case .dictionary:
                    for (key, _) in other {
                        try self[key].merge(with: other[key], typecheck: false)
                    }
                case .array:
                    self = SwiftyJSON(arrayValue + other.arrayValue)
                default:
                    self = other
            }
        } else {
            if typecheck {
                throw SwiftyJSONError.wrongType
            } else {
                self = other
            }
        }
    }
    
    /// Private object
    fileprivate var rawArray: [Any] = []
    fileprivate var rawDictionary: [String: Any] = [:]
    fileprivate var rawString: String = ""
    fileprivate var rawNumber: NSNumber = 0
    fileprivate var rawNull: NSNull = NSNull()
    fileprivate var rawBool: Bool = false
    
    /// SwiftyJSON type, fileprivate setter
    public fileprivate(set) var type: Type = .null
    
    /// Error in SwiftyJSON, fileprivate setter
    public fileprivate(set) var error: SwiftyJSONError?
    
    /// Object in SwiftyJSON
    public var object: Any {
        get {
            switch type {
                case .array:      return rawArray
                case .dictionary: return rawDictionary
                case .string:     return rawString
                case .number:     return rawNumber
                case .bool:       return rawBool
                default:          return rawNull
            }
        }
        set {
            error = nil
            switch unwrap(newValue) {
                case let number as NSNumber:
                    if number.isBool {
                        type = .bool
                        rawBool = number.boolValue
                    } else {
                        type = .number
                        rawNumber = number
                    }
                case let string as String:
                    type = .string
                    rawString = string
                case _ as NSNull:
                    type = .null
                case nil:
                    type = .null
                case let array as [Any]:
                    type = .array
                    rawArray = array
                case let dictionary as [String: Any]:
                    type = .dictionary
                    rawDictionary = dictionary
                default:
                    type = .unknown
                    error = SwiftyJSONError.unsupportedType
            }
        }
    }
    
    /// The static null SwiftyJSON
    @available(*, unavailable, renamed:"null")
    public static var nullJSON: SwiftyJSON { return null }
    public static var null: SwiftyJSON { return SwiftyJSON(NSNull()) }
}

/// Private method to unwarp an object recursively
private func unwrap(_ object: Any) -> Any {
    switch object {
        case let SwiftyJSON as SwiftyJSON:
            return unwrap(SwiftyJSON.object)
        case let array as [Any]:
            return array.map(unwrap)
        case let dictionary as [String: Any]:
            var d = dictionary
            dictionary.forEach { pair in
                d[pair.key] = unwrap(pair.value)
            }
            return d
        default:
            return object
    }
}

public enum Index<T: Any>: Comparable {
    case array(Int)
    case dictionary(DictionaryIndex<String, T>)
    case null
    
    static public func == (lhs: Index, rhs: Index) -> Bool {
        switch (lhs, rhs) {
            case (.array(let left), .array(let right)):           return left == right
            case (.dictionary(let left), .dictionary(let right)): return left == right
            case (.null, .null):                                  return true
            default:                                              return false
        }
    }
    
    static public func < (lhs: Index, rhs: Index) -> Bool {
        switch (lhs, rhs) {
            case (.array(let left), .array(let right)):           return left < right
            case (.dictionary(let left), .dictionary(let right)): return left < right
            default:                                              return false
        }
    }
}

public typealias JSONIndex = Index<SwiftyJSON>
public typealias JSONRawIndex = Index<Any>

extension SwiftyJSON: Swift.Collection {
    
    public typealias Index = JSONRawIndex
    
    public var startIndex: Index {
        switch type {
            case .array:      return .array(rawArray.startIndex)
            case .dictionary: return .dictionary(rawDictionary.startIndex)
            default:          return .null
        }
    }
    
    public var endIndex: Index {
        switch type {
            case .array:      return .array(rawArray.endIndex)
            case .dictionary: return .dictionary(rawDictionary.endIndex)
            default:          return .null
        }
    }
    
    public func index(after i: Index) -> Index {
        switch i {
            case .array(let idx):      return .array(rawArray.index(after: idx))
            case .dictionary(let idx): return .dictionary(rawDictionary.index(after: idx))
            default:                   return .null
        }
    }
    
    public subscript (position: Index) -> (String, SwiftyJSON) {
        switch position {
            case .array(let idx):      return (String(idx), SwiftyJSON(rawArray[idx]))
            case .dictionary(let idx): return (rawDictionary[idx].key, SwiftyJSON(rawDictionary[idx].value))
            default:                   return ("", SwiftyJSON.null)
        }
    }
}

// MARK: - Subscript

/**
 *  To mark both String and Int can be used in subscript.
 */
public enum JSONKey {
    case index(Int)
    case key(String)
}

public protocol JSONSubscriptType {
    var jsonKey: JSONKey { get }
}

extension Int: JSONSubscriptType {
    public var jsonKey: JSONKey {
        return JSONKey.index(self)
    }
}

extension String: JSONSubscriptType {
    public var jsonKey: JSONKey {
        return JSONKey.key(self)
    }
}

extension SwiftyJSON {
    
    /// If `type` is `.array`, return SwiftyJSON whose object is `array[index]`, otherwise return null SwiftyJSON with error.
    fileprivate subscript(index index: Int) -> SwiftyJSON {
        get {
            if type != .array {
                var r = SwiftyJSON.null
                r.error = self.error ?? SwiftyJSONError.wrongType
                return r
            } else if rawArray.indices.contains(index) {
                return SwiftyJSON(rawArray[index])
            } else {
                var r = SwiftyJSON.null
                r.error = SwiftyJSONError.indexOutOfBounds
                return r
            }
        }
        set {
            if type == .array &&
                rawArray.indices.contains(index) &&
                newValue.error == nil {
                rawArray[index] = newValue.object
            }
        }
    }
    
    /// If `type` is `.dictionary`, return SwiftyJSON whose object is `dictionary[key]` , otherwise return null SwiftyJSON with error.
    fileprivate subscript(key key: String) -> SwiftyJSON {
        get {
            var r = SwiftyJSON.null
            if type == .dictionary {
                if let o = rawDictionary[key] {
                    r = SwiftyJSON(o)
                } else {
                    r.error = SwiftyJSONError.notExist
                }
            } else {
                r.error = self.error ?? SwiftyJSONError.wrongType
            }
            return r
        }
        set {
            if type == .dictionary && newValue.error == nil {
                rawDictionary[key] = newValue.object
            }
        }
    }
    
    /// If `sub` is `Int`, return `subscript(index:)`; If `sub` is `String`,  return `subscript(key:)`.
    fileprivate subscript(sub sub: JSONSubscriptType) -> SwiftyJSON {
        get {
            switch sub.jsonKey {
                case .index(let index): return self[index: index]
                case .key(let key):     return self[key: key]
            }
        }
        set {
            switch sub.jsonKey {
                case .index(let index): self[index: index] = newValue
                case .key(let key):     self[key: key] = newValue
            }
        }
    }
    
    /**
     Find a SwiftyJSON in the complex data structures by using array of Int and/or String as path.
     
     Example:
     
     ```
     let SwiftyJSON = SwiftyJSON[data]
     let path = [9,"list","person","name"]
     let name = SwiftyJSON[path]
     ```
     
     The same as: let name = SwiftyJSON[9]["list"]["person"]["name"]
     
     - parameter path: The target SwiftyJSON's path.
     
     - returns: Return a SwiftyJSON found by the path or a null SwiftyJSON with error
     */
    public subscript(path: [JSONSubscriptType]) -> SwiftyJSON {
        get {
            return path.reduce(self) { $0[sub: $1] }
        }
        set {
            switch path.count {
                case 0: return
                case 1: self[sub:path[0]].object = newValue.object
                default:
                    var aPath = path
                    aPath.remove(at: 0)
                    var nextJSON = self[sub: path[0]]
                    nextJSON[aPath] = newValue
                    self[sub: path[0]] = nextJSON
            }
        }
    }
    
    /**
     Find a SwiftyJSON in the complex data structures by using array of Int and/or String as path.
     
     - parameter path: The target SwiftyJSON's path. Example:
     
     let name = SwiftyJSON[9,"list","person","name"]
     
     The same as: let name = SwiftyJSON[9]["list"]["person"]["name"]
     
     - returns: Return a SwiftyJSON found by the path or a null SwiftyJSON with error
     */
    public subscript(path: JSONSubscriptType...) -> SwiftyJSON {
        get {
            return self[path]
        }
        set {
            self[path] = newValue
        }
    }
}

// MARK: - LiteralConvertible

extension SwiftyJSON: Swift.ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension SwiftyJSON: Swift.ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension SwiftyJSON: Swift.ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension SwiftyJSON: Swift.ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension SwiftyJSON: Swift.ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        let dictionary = elements.reduce(into: [String: Any](), { $0[$1.0] = $1.1})
        self.init(dictionary)
    }
}

extension SwiftyJSON: Swift.ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}

// MARK: - Raw

extension SwiftyJSON: Swift.RawRepresentable {
    
    public init?(rawValue: Any) {
        if SwiftyJSON(rawValue).type == .unknown {
            return nil
        } else {
            self.init(rawValue)
        }
    }
    
    public var rawValue: Any {
        return object
    }
    
    public func rawData(options opt: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) throws -> Data {
        guard JSONSerialization.isValidJSONObject(object) else {
            throw SwiftyJSONError.invalidJSON
        }
        
        return try JSONSerialization.data(withJSONObject: object, options: opt)
    }
    
    public func rawString(_ encoding: String.Encoding = .utf8, options opt: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
        do {
            return try _rawString(encoding, options: [.jsonSerialization: opt])
        } catch {
            print("Could not serialize object to SwiftyJSON because:", error.localizedDescription)
            return nil
        }
    }
    
    public func rawString(_ options: [writingOptionsKeys: Any]) -> String? {
        let encoding = options[.encoding] as? String.Encoding ?? String.Encoding.utf8
        let maxObjectDepth = options[.maxObjextDepth] as? Int ?? 10
        do {
            return try _rawString(encoding, options: options, maxObjectDepth: maxObjectDepth)
        } catch {
            print("Could not serialize object to SwiftyJSON because:", error.localizedDescription)
            return nil
        }
    }
    
    fileprivate func _rawString(_ encoding: String.Encoding = .utf8, options: [writingOptionsKeys: Any], maxObjectDepth: Int = 10) throws -> String? {
        guard maxObjectDepth > 0 else { throw SwiftyJSONError.invalidJSON }
        switch type {
            case .dictionary:
                do {
                    if !(options[.castNilToNSNull] as? Bool ?? false) {
                        let jsonOption = options[.jsonSerialization] as? JSONSerialization.WritingOptions ?? JSONSerialization.WritingOptions.prettyPrinted
                        let data = try rawData(options: jsonOption)
                        return String(data: data, encoding: encoding)
                    }
                    
                    guard let dict = object as? [String: Any?] else {
                        return nil
                    }
                    let body = try dict.keys.map { key throws -> String in
                        guard let value = dict[key] else {
                            return "\"\(key)\": null"
                        }
                        guard let unwrappedValue = value else {
                            return "\"\(key)\": null"
                        }
                        
                        let nestedValue = SwiftyJSON(unwrappedValue)
                        guard let nestedString = try nestedValue._rawString(encoding, options: options, maxObjectDepth: maxObjectDepth - 1) else {
                            throw SwiftyJSONError.elementTooDeep
                        }
                        if nestedValue.type == .string {
                            return "\"\(key)\": \"\(nestedString.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
                        } else {
                            return "\"\(key)\": \(nestedString)"
                        }
                    }
                    
                    return "{\(body.joined(separator: ","))}"
                } catch _ {
                    return nil
                }
            case .array:
                do {
                    if !(options[.castNilToNSNull] as? Bool ?? false) {
                        let jsonOption = options[.jsonSerialization] as? JSONSerialization.WritingOptions ?? JSONSerialization.WritingOptions.prettyPrinted
                        let data = try rawData(options: jsonOption)
                        return String(data: data, encoding: encoding)
                    }
                    
                    guard let array = object as? [Any?] else {
                        return nil
                    }
                    let body = try array.map { value throws -> String in
                        guard let unwrappedValue = value else {
                            return "null"
                        }
                        
                        let nestedValue = SwiftyJSON(unwrappedValue)
                        guard let nestedString = try nestedValue._rawString(encoding, options: options, maxObjectDepth: maxObjectDepth - 1) else {
                            throw SwiftyJSONError.invalidJSON
                        }
                        if nestedValue.type == .string {
                            return "\"\(nestedString.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
                        } else {
                            return nestedString
                        }
                    }
                    
                    return "[\(body.joined(separator: ","))]"
                } catch _ {
                    return nil
                }
            case .string: return rawString
            case .number: return rawNumber.stringValue
            case .bool:   return rawBool.description
            case .null:   return "null"
            default:      return nil
        }
    }
}

// MARK: - Printable, DebugPrintable

extension SwiftyJSON: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    
    public var description: String {
        return rawString(options: .prettyPrinted) ?? "unknown"
    }
    
    public var debugDescription: String {
        return description
    }
}

// MARK: - Array

extension SwiftyJSON {
    
    //Optional [SwiftyJSON]
    public var array: [SwiftyJSON]? {
        return type == .array ? rawArray.map { SwiftyJSON($0) } : nil
    }
    
    //Non-optional [SwiftyJSON]
    public var arrayValue: [SwiftyJSON] {
        return self.array ?? []
    }
    
    //Optional [Any]
    public var arrayObject: [Any]? {
        get {
            switch type {
                case .array: return rawArray
                default:     return nil
            }
        }
        set {
            self.object = newValue ?? NSNull()
        }
    }
}

// MARK: - Dictionary

extension SwiftyJSON {
    
    //Optional [String : SwiftyJSON]
    public var dictionary: [String: SwiftyJSON]? {
        if type == .dictionary {
            var d = [String: SwiftyJSON](minimumCapacity: rawDictionary.count)
            rawDictionary.forEach { pair in
                d[pair.key] = SwiftyJSON(pair.value)
            }
            return d
        } else {
            return nil
        }
    }
    
    //Non-optional [String : SwiftyJSON]
    public var dictionaryValue: [String: SwiftyJSON] {
        return dictionary ?? [:]
    }
    
    //Optional [String : Any]
    
    public var dictionaryObject: [String: Any]? {
        get {
            switch type {
                case .dictionary: return rawDictionary
                default:          return nil
            }
        }
        set {
            object = newValue ?? NSNull()
        }
    }
}

// MARK: - Bool

extension SwiftyJSON { // : Swift.Bool
    
    //Optional bool
    public var bool: Bool? {
        get {
            switch type {
                case .bool: return rawBool
                default:    return nil
            }
        }
        set {
            object = newValue ?? NSNull()
        }
    }
    
    //Non-optional bool
    public var boolValue: Bool {
        get {
            switch type {
                case .bool:   return rawBool
                case .number: return rawNumber.boolValue
                case .string: return ["true", "y", "t", "yes", "1"].contains { rawString.caseInsensitiveCompare($0) == .orderedSame }
                default:      return false
            }
        }
        set {
            object = newValue
        }
    }
}

// MARK: - String

extension SwiftyJSON {
    
    //Optional string
    public var string: String? {
        get {
            switch type {
                case .string: return object as? String
                default:      return nil
            }
        }
        set {
            object = newValue ?? NSNull()
        }
    }
    
    //Non-optional string
    public var stringValue: String {
        get {
            switch type {
                case .string: return object as? String ?? ""
                case .number: return rawNumber.stringValue
                case .bool:   return (object as? Bool).map { String($0) } ?? ""
                default:      return ""
            }
        }
        set {
            object = newValue
        }
    }
}

// MARK: - Number

extension SwiftyJSON {
    
    //Optional number
    public var number: NSNumber? {
        get {
            switch type {
                case .number: return rawNumber
                case .bool:   return NSNumber(value: rawBool ? 1 : 0)
                default:      return nil
            }
        }
        set {
            object = newValue ?? NSNull()
        }
    }
    
    //Non-optional number
    public var numberValue: NSNumber {
        get {
            switch type {
                case .string:
                    let decimal = NSDecimalNumber(string: object as? String)
                    return decimal == .notANumber ? .zero : decimal
                case .number: return object as? NSNumber ?? NSNumber(value: 0)
                case .bool: return NSNumber(value: rawBool ? 1 : 0)
                default: return NSNumber(value: 0.0)
            }
        }
        set {
            object = newValue
        }
    }
}

// MARK: - Null

extension SwiftyJSON {
    
    public var null: NSNull? {
        set {
            object = NSNull()
        }
        get {
            switch type {
                case .null: return rawNull
                default:    return nil
            }
        }
    }
    public func exists() -> Bool {
        if let errorValue = error, (400...1000).contains(errorValue.errorCode) {
            return false
        }
        return true
    }
}

// MARK: - URL

extension SwiftyJSON {
    
    //Optional URL
    public var url: URL? {
        get {
            switch type {
                case .string:
                    // Check for existing percent escapes first to prevent double-escaping of % character
                    if rawString.range(of: "%[0-9A-Fa-f]{2}", options: .regularExpression, range: nil, locale: nil) != nil {
                        return Foundation.URL(string: rawString)
                    } else if let encodedString_ = rawString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                        // We have to use `Foundation.URL` otherwise it conflicts with the variable name.
                        return Foundation.URL(string: encodedString_)
                    } else {
                        return nil
                    }
                default:
                    return nil
            }
        }
        set {
            object = newValue?.absoluteString ?? NSNull()
        }
    }
}

// MARK: - Int, Double, Float, Int8, Int16, Int32, Int64

extension SwiftyJSON {
    
    public var double: Double? {
        get {
            return number?.doubleValue
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: newValue)
            } else {
                object = NSNull()
            }
        }
    }
    
    public var doubleValue: Double {
        get {
            return numberValue.doubleValue
        }
        set {
            object = NSNumber(value: newValue)
        }
    }
    
    public var float: Float? {
        get {
            return number?.floatValue
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: newValue)
            } else {
                object = NSNull()
            }
        }
    }
    
    public var floatValue: Float {
        get {
            return numberValue.floatValue
        }
        set {
            object = NSNumber(value: newValue)
        }
    }
    
    public var int: Int? {
        get {
            return number?.intValue
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: newValue)
            } else {
                object = NSNull()
            }
        }
    }
    
    public var intValue: Int {
        get {
            return numberValue.intValue
        }
        set {
            object = NSNumber(value: newValue)
        }
    }
    
    public var uInt: UInt? {
        get {
            return number?.uintValue
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: newValue)
            } else {
                object = NSNull()
            }
        }
    }
    
    public var uIntValue: UInt {
        get {
            return numberValue.uintValue
        }
        set {
            object = NSNumber(value: newValue)
        }
    }
    
    public var int8: Int8? {
        get {
            return number?.int8Value
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: Int(newValue))
            } else {
                object =  NSNull()
            }
        }
    }
    
    public var int8Value: Int8 {
        get {
            return numberValue.int8Value
        }
        set {
            object = NSNumber(value: Int(newValue))
        }
    }
    
    public var uInt8: UInt8? {
        get {
            return number?.uint8Value
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: newValue)
            } else {
                object =  NSNull()
            }
        }
    }
    
    public var uInt8Value: UInt8 {
        get {
            return numberValue.uint8Value
        }
        set {
            object = NSNumber(value: newValue)
        }
    }
    
    public var int16: Int16? {
        get {
            return number?.int16Value
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: newValue)
            } else {
                object =  NSNull()
            }
        }
    }
    
    public var int16Value: Int16 {
        get {
            return numberValue.int16Value
        }
        set {
            object = NSNumber(value: newValue)
        }
    }
    
    public var uInt16: UInt16? {
        get {
            return number?.uint16Value
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: newValue)
            } else {
                object =  NSNull()
            }
        }
    }
    
    public var uInt16Value: UInt16 {
        get {
            return numberValue.uint16Value
        }
        set {
            object = NSNumber(value: newValue)
        }
    }
    
    public var int32: Int32? {
        get {
            return number?.int32Value
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: newValue)
            } else {
                object =  NSNull()
            }
        }
    }
    
    public var int32Value: Int32 {
        get {
            return numberValue.int32Value
        }
        set {
            object = NSNumber(value: newValue)
        }
    }
    
    public var uInt32: UInt32? {
        get {
            return number?.uint32Value
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: newValue)
            } else {
                object =  NSNull()
            }
        }
    }
    
    public var uInt32Value: UInt32 {
        get {
            return numberValue.uint32Value
        }
        set {
            object = NSNumber(value: newValue)
        }
    }
    
    public var int64: Int64? {
        get {
            return number?.int64Value
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: newValue)
            } else {
                object =  NSNull()
            }
        }
    }
    
    public var int64Value: Int64 {
        get {
            return numberValue.int64Value
        }
        set {
            object = NSNumber(value: newValue)
        }
    }
    
    public var uInt64: UInt64? {
        get {
            return number?.uint64Value
        }
        set {
            if let newValue = newValue {
                object = NSNumber(value: newValue)
            } else {
                object =  NSNull()
            }
        }
    }
    
    public var uInt64Value: UInt64 {
        get {
            return numberValue.uint64Value
        }
        set {
            object = NSNumber(value: newValue)
        }
    }
}

// MARK: - Comparable

extension SwiftyJSON: Swift.Comparable {}

public func == (lhs: SwiftyJSON, rhs: SwiftyJSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
        case (.number, .number): return lhs.rawNumber == rhs.rawNumber
        case (.string, .string): return lhs.rawString == rhs.rawString
        case (.bool, .bool):     return lhs.rawBool == rhs.rawBool
        case (.array, .array):   return lhs.rawArray as NSArray == rhs.rawArray as NSArray
        case (.dictionary, .dictionary): return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
        case (.null, .null):     return true
        default:                 return false
    }
}

public func <= (lhs: SwiftyJSON, rhs: SwiftyJSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
        case (.number, .number): return lhs.rawNumber <= rhs.rawNumber
        case (.string, .string): return lhs.rawString <= rhs.rawString
        case (.bool, .bool):     return lhs.rawBool == rhs.rawBool
        case (.array, .array):   return lhs.rawArray as NSArray == rhs.rawArray as NSArray
        case (.dictionary, .dictionary): return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
        case (.null, .null):     return true
        default:                 return false
    }
}

public func >= (lhs: SwiftyJSON, rhs: SwiftyJSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
        case (.number, .number): return lhs.rawNumber >= rhs.rawNumber
        case (.string, .string): return lhs.rawString >= rhs.rawString
        case (.bool, .bool):     return lhs.rawBool == rhs.rawBool
        case (.array, .array):   return lhs.rawArray as NSArray == rhs.rawArray as NSArray
        case (.dictionary, .dictionary): return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
        case (.null, .null):     return true
        default:                 return false
    }
}

public func > (lhs: SwiftyJSON, rhs: SwiftyJSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
        case (.number, .number): return lhs.rawNumber > rhs.rawNumber
        case (.string, .string): return lhs.rawString > rhs.rawString
        default:                 return false
    }
}

public func < (lhs: SwiftyJSON, rhs: SwiftyJSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
        case (.number, .number): return lhs.rawNumber < rhs.rawNumber
        case (.string, .string): return lhs.rawString < rhs.rawString
        default:                 return false
    }
}

private let trueNumber = NSNumber(value: true)
private let falseNumber = NSNumber(value: false)
private let trueObjCType = String(cString: trueNumber.objCType)
private let falseObjCType = String(cString: falseNumber.objCType)

// MARK: - NSNumber: Comparable

extension NSNumber {
    fileprivate var isBool: Bool {
        let objCType = String(cString: self.objCType)
        if (self.compare(trueNumber) == .orderedSame && objCType == trueObjCType) || (self.compare(falseNumber) == .orderedSame && objCType == falseObjCType) {
            return true
        } else {
            return false
        }
    }
}

func == (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
        case (false, true): return false
        case (true, false): return false
        default:            return lhs.compare(rhs) == .orderedSame
    }
}

func != (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return !(lhs == rhs)
}

func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    
    switch (lhs.isBool, rhs.isBool) {
        case (false, true): return false
        case (true, false): return false
        default:            return lhs.compare(rhs) == .orderedAscending
    }
}

func > (lhs: NSNumber, rhs: NSNumber) -> Bool {
    
    switch (lhs.isBool, rhs.isBool) {
        case (false, true): return false
        case (true, false): return false
        default:            return lhs.compare(rhs) == ComparisonResult.orderedDescending
    }
}

func <= (lhs: NSNumber, rhs: NSNumber) -> Bool {
    
    switch (lhs.isBool, rhs.isBool) {
        case (false, true): return false
        case (true, false): return false
        default:            return lhs.compare(rhs) != .orderedDescending
    }
}

func >= (lhs: NSNumber, rhs: NSNumber) -> Bool {
    
    switch (lhs.isBool, rhs.isBool) {
        case (false, true): return false
        case (true, false): return false
        default:            return lhs.compare(rhs) != .orderedAscending
    }
}

public enum writingOptionsKeys {
    case jsonSerialization
    case castNilToNSNull
    case maxObjextDepth
    case encoding
}

// MARK: - SwiftyJSON: Codable
extension SwiftyJSON: Codable {
    private static var codableTypes: [Codable.Type] {
        return [
            Bool.self,
            Int.self,
            Int8.self,
            Int16.self,
            Int32.self,
            Int64.self,
            UInt.self,
            UInt8.self,
            UInt16.self,
            UInt32.self,
            UInt64.self,
            Double.self,
            String.self,
            [SwiftyJSON].self,
            [String: SwiftyJSON].self
        ]
    }
    public init(from decoder: Decoder) throws {
        var object: Any?
        
        if let container = try? decoder.singleValueContainer(), !container.decodeNil() {
            for type in SwiftyJSON.codableTypes {
                if object != nil {
                    break
                }
                // try to decode value
                switch type {
                    case let boolType as Bool.Type:
                        object = try? container.decode(boolType)
                    case let intType as Int.Type:
                        object = try? container.decode(intType)
                    case let int8Type as Int8.Type:
                        object = try? container.decode(int8Type)
                    case let int32Type as Int32.Type:
                        object = try? container.decode(int32Type)
                    case let int64Type as Int64.Type:
                        object = try? container.decode(int64Type)
                    case let uintType as UInt.Type:
                        object = try? container.decode(uintType)
                    case let uint8Type as UInt8.Type:
                        object = try? container.decode(uint8Type)
                    case let uint16Type as UInt16.Type:
                        object = try? container.decode(uint16Type)
                    case let uint32Type as UInt32.Type:
                        object = try? container.decode(uint32Type)
                    case let uint64Type as UInt64.Type:
                        object = try? container.decode(uint64Type)
                    case let doubleType as Double.Type:
                        object = try? container.decode(doubleType)
                    case let stringType as String.Type:
                        object = try? container.decode(stringType)
                    case let jsonValueArrayType as [SwiftyJSON].Type:
                        object = try? container.decode(jsonValueArrayType)
                    case let jsonValueDictType as [String: SwiftyJSON].Type:
                        object = try? container.decode(jsonValueDictType)
                    default:
                        break
                }
            }
        }
        self.init(object ?? NSNull())
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if object is NSNull {
            try container.encodeNil()
            return
        }
        switch object {
            case let intValue as Int:
                try container.encode(intValue)
            case let int8Value as Int8:
                try container.encode(int8Value)
            case let int32Value as Int32:
                try container.encode(int32Value)
            case let int64Value as Int64:
                try container.encode(int64Value)
            case let uintValue as UInt:
                try container.encode(uintValue)
            case let uint8Value as UInt8:
                try container.encode(uint8Value)
            case let uint16Value as UInt16:
                try container.encode(uint16Value)
            case let uint32Value as UInt32:
                try container.encode(uint32Value)
            case let uint64Value as UInt64:
                try container.encode(uint64Value)
            case let doubleValue as Double:
                try container.encode(doubleValue)
            case let boolValue as Bool:
                try container.encode(boolValue)
            case let stringValue as String:
                try container.encode(stringValue)
            case is [Any]:
                let jsonValueArray = array ?? []
                try container.encode(jsonValueArray)
            case is [String: Any]:
                let jsonValueDictValue = dictionary ?? [:]
                try container.encode(jsonValueDictValue)
            default:
                break
        }
    }
}