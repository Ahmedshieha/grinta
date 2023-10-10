//
//  BaseResponseProtocol.swift
//  Youssef
//
//  Created by Youssef on 16/12/2021.
//  Copyright © 2021 Youssef. All rights reserved.
//


import Foundation

protocol BaseResponseProtocol: Codable {
    associatedtype NetworkModel: Codable
    var data: NetworkModel? { get set }
    var isSuccess: Bool { get }
//    var errors: UnknownType<String, [String]>? { get }
    var message: String? { get }
    var status: String? { get }



}

extension BaseResponseProtocol {
    public var isSuccess: Bool {
//        return true
        return (status == "success")
    }
}

struct BaseResponse<T: Codable>: BaseResponseProtocol {
    var message: String?
    var status: String?
    var data: T?
    var is_available : Bool?
}

struct EmptyData: Codable { }

struct ReceiverData: Codable {
    let id, phone: String?
    let image: String?
    let fullname: String?
}
enum OrderStatus: String, Codable {
    case pre_pending
    case pending
    case driver_accept
    case driver_rejected
    case driver_start_order
    case driver_pre_finished
    case driver_finished_delivery
    case client_cancel
    case driver_cancel
    case paid
    case driver_finished_package
    case restaurant_accept
    case restaurant_ready
    case restaurant_reject
    case restaurant_accept_order
    case request_cancel
    case driver_accept_cancel
    case driver_reject_cancel
    case restaurant_ready_order
    case restaurant_reject_order
    case restaurant_search_on_driver
}
// MARK: - Links
struct Links: Codable {
    let first, last: String?
    let prev: String?
    let next: String?
}
