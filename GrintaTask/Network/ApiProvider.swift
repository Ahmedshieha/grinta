//
//  ApiProvider.swift
//  Currency
//
//  Created by MacBook on 11/10/2023.
//

import Foundation
import Moya


 // enum for endPoints that i use

enum HomeProvider: TargetType {
    case getMatches
}

// extension for enum of targrtType which make it easy to handle url , methods , task and path of url 
extension HomeProvider : AccessTokenAuthorizable {
    
    var baseURL: URL {
        URL(string: Constants.baseUrl)!
    }
    
    var path: String {
        switch self {
        case.getMatches :
            return "competitions/2021/matches"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case.getMatches :
            return.get
        }
    }
    
    var task: Task {
        switch self {
        case.getMatches :
            return .requestPlain

        }
    }
    
    var headers: [String : String]? {
        ["X-Auth-Token":"\(Constants.apiKey)"]
    }
    
    var authorizationType: AuthorizationType? {
        return.bearer
    }
    
    
    
}
