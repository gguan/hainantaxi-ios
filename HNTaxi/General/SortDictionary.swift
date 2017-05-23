//
//  SortDictionary.swift
//  HNTaxi
//
//  Created by Tbxark on 23/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//


public struct SortDictionary<Key: Hashable, Value>: Collection, ExpressibleByDictionaryLiteral {
    
    
    public typealias Index = Int
    public typealias Element = (key: Key, value: Value)
    public typealias Generator = IndexingIterator<SortDictionary<Key, Value>>
    
    public private(set) var allKeys: [Key]
    public private(set) var values: [Key: Value]
    
    
    public init() {
        allKeys = []
        values = [:]
    }
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        var keys = [Key]()
        var values = [Key: Value]()
        for e in elements {
            keys.append(e.0)
            values[e.0] = e.1
        }
        self.allKeys = keys
        self.values = values
    }
    
    
    
    // MARK: - Indexable
    public var startIndex: Index  { return allKeys.startIndex }
    public var endIndex: Index { return allKeys.endIndex }
    public func index(after i: Int) -> Int {
        return startIndex + i
    }
    public subscript(index: SortDictionary.Index) -> Element {
        get {
            let key = allKeys[index]
            return (key, values[allKeys[index]]!)
        }
    }
    
    
    
    /// Dict
    public mutating func add(value: Value?, forKey key: Key) {
        guard let v = value else {
            _ = removeValue(ForKey: key)
            return
        }
        if !allKeys.contains(key) {
            allKeys.append(key)
        }
        values[key] = v
    }
    
    public mutating func removeValue(ForKey key: Key) -> Bool {
        guard let i = allKeys.index(of: key) else { return false }
        allKeys.remove(at: i)
        values.removeValue(forKey: key)
        return true
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return values[key]
        }
        set {
            add(value: newValue, forKey: key)
        }
    }
}


