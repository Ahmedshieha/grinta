//
//  ApiService.swift
//  Currency
//
//  Created by MacBook on 28/10/2022.
//

import Foundation
import Moya


// class for handle api methods
class ApiService {
    
    static let shared = ApiService()
    
    // moya provider to take AccessToken if availaple and print logger to test your data and request
    
    let provider = MoyaProvider<ApiProvider>(
        plugins : [
            AccessTokenPlugin { _ in
                return ""
                
            },
            NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions : .verbose) )
        ]
    )
    
    
    // method to get available currencies
    
    func getSymbolsWithMoya(completion : @escaping (Result <[String:String] , Error>)-> Void) {
        provider.request(.getMatches) { result in
            switch result {
            case.success(let response) :
                do {
                    let jsonData = try JSONDecoder().decode(Symbols.self, from: response.data)
                    completion(.success(jsonData.symbols))
                    
                }
                catch let error {
                    print(error.localizedDescription)
                }
            case.failure(let error) :
                print(error.localizedDescription)
            }
        }
    }
   
    
    
    
}
