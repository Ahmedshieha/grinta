//
//  JsonEncadable.swift
//  Youssef
//
//  Created by Youssef on 7/14/22.
//  Copyright © 2022 Youssef. All rights reserved.
//

import Foundation

protocol JsonEncadable {
    var json: [String: Any] { get }
}

extension JsonEncadable {
    var json: [String: Any] {
        let mirror = Mirror(reflecting: self)
        var dictEncoded = [String: Any]()
        mirror.children.forEach { child in
            dictEncoded[child.label!] = child.value
        }
        let body = dictEncoded.compactMapValues({$0})
        return body
    }
}

extension Dictionary : JsonEncadable where Key == String, Value == Any {
    var json: [String: Any] {
        return self
    }
}
