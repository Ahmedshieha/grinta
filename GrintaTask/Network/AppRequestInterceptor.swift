//
//  AppRequestInterceptor.swift
//  Youssef
//
//  Created by Youssef on 7/14/22.
//  Copyright © 2022 Youssef. All rights reserved.
//

import Foundation
import Alamofire

class AppRequestInterceptor: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.setValue("os", forHTTPHeaderField: "ios")
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("\(-1)", forHTTPHeaderField: "time-zone-country-id")

        
        
        completion(.success(urlRequest))
      }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let statusCode = request.response?.statusCode
        if statusCode == 401 {
            completion(.doNotRetryWithError(MyAppError.basicError))
        } else {
            completion(.doNotRetryWithError(MyAppError.networkError))
        }
      }
}
