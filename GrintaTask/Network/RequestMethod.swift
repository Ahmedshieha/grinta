//
//  RequestMethod.swift
//  SaudiMarch
//
//  Created by Youssef on 02/10/2022.
//  Copyright © 2022 Youssef. All rights reserved.
//

import Foundation
import Alamofire
import SwiftUI

@propertyWrapper
struct GET<T: Codable> {
    
    var wrappedValue: any Network<T> {
        mutating get {
            return request
        }
    }
    
    private var request: any Network<T>

    init(url: RequestUrl, encoding: RequestEncodingType = .json) {
        request = AsyncRequest<T>(request: NetworkRequest(url: url, method: .get, encoding: encoding))
    }
}

@propertyWrapper
struct POST<T: Codable> {
    
    var wrappedValue: any Network<T> {
        mutating get {
            return request
        }
    }
    
    private var request: any Network<T>

    init(url: RequestUrl, encoding: RequestEncodingType = .json) {
        request = AsyncRequest<T>(request: NetworkRequest(url: url, method: .post, encoding: encoding))
    }
}

@propertyWrapper
struct DELETE<T: Codable> {
    
    var wrappedValue: any Network<T> {
        mutating get {
            return request
        }
    }
    
    private var request: any Network<T>

    init(url: RequestUrl, encoding: RequestEncodingType = .json) {
        request = AsyncRequest<T>(request: NetworkRequest(url: url, method: .delete, encoding: encoding))
    }
}
