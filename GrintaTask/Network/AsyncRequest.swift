//
//  AsyncRequest.swift
//  Youssef
//
//  Created by Youssef on 7/14/22.
//  Copyright © 2022 Youssef. All rights reserved.
//
import Foundation
import Alamofire
import Combine

typealias RequestPublisher<T: Codable> = AnyPublisher<NetworkState<T>, Never>

protocol Network<T>: AnyObject {
    associatedtype T: Codable
    var request: RequestReusable { get }
    func asPublisher() async -> RequestPublisher<T>
    func asPublisher(data: [UploadData]) async -> RequestPublisher<T>
    func asAnyPublisher() async -> RequestPublisher<T>
    func withBody(_ body: JsonEncadable?, _ arrayBody: [String: Any]?) -> Self
}

class AsyncRequest<T: Codable>: Network {
    
    var request: RequestReusable
    
    private lazy var interceptor = AppRequestInterceptor()
    
    init(request: RequestReusable) {
        self.request = request
    }
    
    private lazy var sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest = 60
        return Session(configuration: configuration, interceptor: interceptor)
    }()
    
    func withBody(_ body: JsonEncadable?, _ arrayBody: [String: Any]? = nil) -> Self {
//        if arrayBody != nil {
//            self.request.arrayBody = arrayBody!
//
//        }else{
            self.request.body = body

//        }
        return self
    }
    
    fileprivate func handleNetworkResult(_ response: DataResponse<BaseResponse<T>, AFError>, promise: (Result<NetworkState<T>, Never>) -> Void) {
        switch response.result {
        case .success(let model):
            let state = NetworkState<T>(model)
            promise(.success(state))
        case .failure(let error):
            debugPrint("Model Name: \(String(describing: T.self)) has request error", error.asAFError?.errorDescription, error.localizedDescription, error.failureReason, error.localizedDescription)
            promise(.success(.fail(MyAppError.networkError)))
        }
    }
    
    fileprivate func handleNetworkResult(_ response: DataResponse<T, AFError>, promise: (Result<NetworkState<T>, Never>) -> Void) {
        switch response.result {
        case .success(let model):
            let state = NetworkState<T>(model as! BaseResponse<T>)
            promise(.success(state))
        case .failure(let error):
            debugPrint("Model Name: \(String(describing: T.self)) has request error", error.asAFError?.errorDescription, error.localizedDescription, error.failureReason, error.localizedDescription)
            promise(.success(.fail(MyAppError.networkError)))
        }
    }
    @discardableResult
    func asPublisher(data: [UploadData]) async -> RequestPublisher<T> {
        Future {[weak self] promise in
            guard let self else { return }
            self.sessionManager
                .upload(multipartFormData: { multipartFormData in
                    data.forEach {
                        multipartFormData.append($0.data, withName: $0.name, fileName: $0.fileName, mimeType: $0.mimeType)
                    }
                    
                    for (key, value) in self.request.body?.json ?? [:] {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                    }
                }, with: self.request)
                .responseDecodable(of: BaseResponse<T>.self, completionHandler: { response in
                    self.handleNetworkResult(response, promise: promise)
                })
                .uploadProgress { (progress) in
#if DEBUG
                    print(String(format: "%.1f", progress.fractionCompleted * 100))
#endif
                }
        }.eraseToAnyPublisher()
    }
    
    @discardableResult
    func asPublisher() async -> RequestPublisher<T> {
        var statusCodeSeq = (200..<499).sorted()
        if let index = statusCodeSeq.firstIndex(of: 401) { statusCodeSeq.remove(at: index) }
        return Future {[weak self] promise in
            guard let self else {
                promise(.success(.fail(MyAppError.networkError)))
                return
            }
            self.sessionManager
                .request(self.request)
                .validate(statusCode: statusCodeSeq)
                .responseDecodable(of: BaseResponse<T>.self, completionHandler: { response in
                    self.handleNetworkResult(response, promise: promise)
                })
        }.eraseToAnyPublisher()
    }
    
    @discardableResult
    func asAnyPublisher() async -> RequestPublisher<T> {
        var statusCodeSeq = (200..<499).sorted()
        if let index = statusCodeSeq.firstIndex(of: 401) { statusCodeSeq.remove(at: index) }
        return Future {[weak self] promise in
            guard let self else {
                promise(.success(.fail(MyAppError.networkError)))
                return
            }
            self.sessionManager
                .request(self.request)
                .validate(statusCode: statusCodeSeq)
                .responseDecodable(of: T.self, completionHandler: { response in
                    self.handleNetworkResult(response, promise: promise)
                })
        }.eraseToAnyPublisher()
    }
    
    @discardableResult
    func asAnyPublisher(data: [UploadData]) async -> RequestPublisher<T> {
        Future {[weak self] promise in
            guard let self else { return }
            self.sessionManager
                .upload(multipartFormData: { multipartFormData in
                    data.forEach {
                        multipartFormData.append($0.data, withName: $0.name, fileName: $0.fileName, mimeType: $0.mimeType)
                    }
                    
                    for (key, value) in self.request.body?.json ?? [:] {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                    }
                }, with: self.request)
                .responseDecodable(of: T.self, completionHandler: { response in
                    self.handleNetworkResult(response, promise: promise)
                })
                .uploadProgress { (progress) in
#if DEBUG
                    print(String(format: "%.1f", progress.fractionCompleted * 100))
#endif
                }
        }.eraseToAnyPublisher()
    }
}
