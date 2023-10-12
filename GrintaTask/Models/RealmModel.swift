////
////  RealmModel.swift
////  GrintaTask
////
////  Created by Ahmed Reda on 12/10/2023.
////
//
//import Foundation
//import RealmSwift
//
//
//class MatchObject: Object {
//    internal init(id: Int? = 0, utcDate: String? = "", status: String? = "", matchday: Int? = 0, stage: String? = "", lastUpdated: String? = "", score: ScoreObject? = nil, homeTeam: TeamObject? = nil, awayTeam: TeamObject? = nil, favorite: Bool? = false) {
//        self.id = id
//        self.utcDate = utcDate
//        self.status = status
//        self.matchday = matchday
//        self.stage = stage
//        self.lastUpdated = lastUpdated
//        self.score = score
//        self.homeTeam = homeTeam
//        self.awayTeam = awayTeam
//        self.favorite = favorite
//    }
//
//  @Persisted var id: Int? = 0
////    let season: Season?
//  @Persisted var utcDate: String? = ""
//  @Persisted var status: String? = ""
//  @Persisted var matchday: Int? = 0
//  @Persisted var stage: String? = ""
//  @Persisted var lastUpdated: String? = ""
//  @Persisted var score: ScoreObject?
//  @Persisted var homeTeam: TeamObject?
//  @Persisted var awayTeam: TeamObject?
//  @Persisted var favorite : Bool? = false
//}
//
//
//class TeamObject : Object {
//    internal init(id: Int? = 0, name: String? = "") {
//        self.id = id
//        self.name = name
//    }
//
//    @Persisted var id: Int? = 0
//    @Persisted var name: String? = ""
//}
//
//
//class ScoreObject: Object {
//    internal init(winner: String = "", duration: String? = "", fullTime: ExtraTimeObject? = nil, halfTime: ExtraTimeObject? = nil, extraTime: ExtraTimeObject? = nil, penalties: ExtraTimeObject? = nil) {
//        self.winner = winner
//        self.duration = duration
//        self.fullTime = fullTime
//        self.halfTime = halfTime
//        self.extraTime = extraTime
//        self.penalties = penalties
//    }
//
//
//
//    @Persisted var winner : String = ""
//    @Persisted var duration: String? = ""
//    @Persisted var fullTime: ExtraTimeObject?
//    @Persisted var halfTime : ExtraTimeObject?
//    @Persisted var extraTime : ExtraTimeObject?
//    @Persisted var penalties: ExtraTimeObject?
//}
//
//// MARK: - ExtraTime
//class ExtraTimeObject: Object {
//    internal init(homeTeam: Int? = 0, awayTeam: Int? = 0) {
//        self.homeTeam = homeTeam
//        self.awayTeam = awayTeam
//    }
//
//    @Persisted var homeTeam : Int? = 0
//    @Persisted var awayTeam: Int? = 0
//}
