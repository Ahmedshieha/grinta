//
//  MatchModel.swift
//  GrintaTask
//
//  Created by Ahmed Reda on 11/10/2023.
//

import Foundation

struct BaseModel : Codable {
    
    let count : Int?
    let competition: Competition?
    let matches : [Match]?
    
    
}


struct Competition : Codable {
    let id : Int?
    let area :  Area?
    let name : String?
    let code : String?
    let plan : String?
    let lastUpdated : String?
    
}


struct Area : Codable {
    let id : Int?
    let name : String?
}

struct Match: Codable {
    let id: Int?
    let season: Season?
    let utcDate: String?
    let status: String?
    let matchday: Int?
    let stage: String?
    let lastUpdated: String?
    let odds: Odds?
    let score: Score?
    let homeTeam, awayTeam: Team?
    let referees: [Referee]?
}

// MARK: - Team
struct Team: Codable {
    let id: Int?
    let name: String?
}

// MARK: - Odds
struct Odds: Codable {
    let msg: String?
}

// MARK: - Referee
struct Referee: Codable {
    let id: Int?
    let name, role, nationality: String?
}

// MARK: - Score
struct Score: Codable {
    let winner, duration: String?
    let fullTime, halfTime, extraTime, penalties: ExtraTime?
}

// MARK: - ExtraTime
struct ExtraTime: Codable {
    let homeTeam, awayTeam: Int?
}

// MARK: - Season
struct Season: Codable {
    let id: Int?
    let startDate, endDate: String?
    let currentMatchday: Int?
}

