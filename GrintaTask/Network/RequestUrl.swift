//
//  RequestUrl.swift
//  Youssef
//
//  Created by Youssef on 7/14/22.
//  Copyright © 2022 Youssef. All rights reserved.
//

import Foundation

enum RequestUrl {
    case full(String)
    case path(String)
    case urlPathParam(path: String)
//    case queryUrl(url: String, query: JsonEncadable)
    
    var value: String {
        
        let baseUrl = "https://api.football-data.org/v2/competitions/2021/matches"
        
        switch self {
        case .full(let url):
            return url
            
        case.path(let path):
            return baseUrl + path
            
        case .urlPathParam(let path):
            let fullUrl = "\(baseUrl)\(path)"
            return fullUrl
            
//        case .queryUrl(let query, let url):
//            var fullUrl = "\(baseUrl)\(url)?"
//
//            query.json.forEach {
//                // fullUrl += "&"
//                fullUrl += "\($0.key)=\($0.value)&"
//            }
//
//            fullUrl = String(fullUrl.dropLast())
//            // fullUrl = fullUrl.replacingOccurrences(of: "?&", with: "?")
//            return fullUrl
        }
    }
}
