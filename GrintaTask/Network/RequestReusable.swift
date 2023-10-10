//
// RequestReusable.swift
// SaudiMarch
//
// Created by Youssef on 19/10/2022.
// Copyright © 2022 Youssef. All rights reserved.
//
import Foundation
import Alamofire
import Combine
protocol RequestReusable: Alamofire.URLRequestConvertible, AnyObject {
    var body: JsonEncadable? { get set }
    //    var arrayBody: [String: Any]? { get set }
    func addPathVariables(path: [String])
    func addHeaderVariables(_ customHeaders: JsonEncadable?)
}
class NetworkRequest: RequestReusable {
    init(url: RequestUrl, method: HTTPMethod, encoding: RequestEncodingType = .json) {
        self.urlReq = url
        self.method = method
        self.encoding = encoding
    }
    var body: JsonEncadable?
    //    var arrayBody: [String: Any]?
    
    private let urlReq: RequestUrl
    private let method: HTTPMethod
    private let encoding: RequestEncodingType
    private var pathVariables = ""
    private var customHeaders: JsonEncadable?
    
    func addPathVariables(path: [String]) {
        pathVariables = path.joined(separator: "/")
    }
    
    func addHeaderVariables(_ customHeaders: JsonEncadable?) {
        self.customHeaders = customHeaders
    }
    
    func asURLRequest() throws -> URLRequest {
        let urlString = urlReq.value.appending(pathVariables).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        // urlRequest.setValue(Constants.lang, forHTTPHeaderField: "lang")
        // urlRequest.setValue(Constants.os, forHTTPHeaderField: "ios")
        // urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        // urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        if let authorization = UserDefaults.userData?.token {
            urlRequest.setValue("authorization", forHTTPHeaderField: "Authorization")
//        }
        
        if let customHeaders {
            for (k, v) in customHeaders.json {
                urlRequest.setValue("\(v)", forHTTPHeaderField: "\(k)")
            }
        }
        //      if arrayBody != nil {
        //          return try encoding.value.encode(urlRequest, with: arrayBody!)
        //      }else{
        return try encoding.value.encode(urlRequest, with: body?.json)
        //      }
    }
}

