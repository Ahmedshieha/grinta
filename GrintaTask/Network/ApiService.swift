//
//  ApiService.swift
//  Currency
//
//  Created by MacBook on 28/10/2023.
//

import Foundation
import Moya



protocol Network  {
    var provider : MoyaProvider<ApiProvider> {get}
    func getMatches(completion : @escaping (Result <BaseModel , Error>)-> Void)
}
// class for handle api methods
struct NetworkManager  : Network {

    let provider = MoyaProvider<ApiProvider>(plugins : [NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions:.verbose))]
    )
    
    func getMatches(completion : @escaping (Result <BaseModel , Error>)-> Void) {
        request(target: .getMatches, completion: completion)
    }
}

private extension NetworkManager {
    private func request<T: Decodable>(target: ApiProvider, completion: @escaping (Result<T, Error>) -> ()) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(T.self, from: response.data)
                    completion(.success(results))
                } catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
