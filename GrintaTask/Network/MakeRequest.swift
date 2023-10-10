//
//  MakeRequest.swift
//  SaudiMarch
//
//  Created by Youssef on 19/10/2022.
//  Copyright © 2022 Youssef. All rights reserved.
//

import Foundation

protocol RequestMaker<T>: AnyObject {
    associatedtype T: Codable
    var network: any Network<T> { get }
    func addPathVariables(path: String...) -> Self
    func addHeaderVariables(_ customHeaders: JsonEncadable?) -> Self
    func makeRequest(with body: JsonEncadable?) async -> RequestPublisher<T>
    func makeRequest(with body: JsonEncadable?, uploadData: [UploadData]) async -> RequestPublisher<T>
//    func makeRequest(arrayBody: [String: Any]?) async -> RequestPublisher<T>
}

extension RequestMaker {
    func makeSomeModelRequest(with body: JsonEncadable? = nil) async -> RequestPublisher<T> {
        await network
            .withBody(body, nil)
            .asAnyPublisher()
            .eraseToAnyPublisher()
    }
    
    func makeRequest(with body: JsonEncadable? = nil) async -> RequestPublisher<T> {
        await network
            .withBody(body, nil)
            .asPublisher()
            .eraseToAnyPublisher()
    }
//    func makeRequest(arrayBody: [String: Any]? = nil) async -> RequestPublisher<T> {
//        await network
//            .withBody(nil, arrayBody)
//            .asPublisher()
//            .eraseToAnyPublisher()
//    }
    func makeRequest(with body: JsonEncadable? = nil, uploadData: [UploadData]) async -> RequestPublisher<T> {
        await network
            .withBody(body, nil)
            .asPublisher(data: uploadData)
            .eraseToAnyPublisher()
    }
    
    func addPathVariables(path: String...) -> Self {
        network.request.addPathVariables(path: path)
        return self
      }
    
    func addHeaderVariables(_ customHeaders: JsonEncadable?) -> Self {
        network.request.addHeaderVariables(customHeaders)
        return self
      }
}
