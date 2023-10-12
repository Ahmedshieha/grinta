//
//  Helper.swift
//  GrintaTask
//
//  Created by Ahmed Reda on 12/10/2023.
//

import Foundation


public func getCurrentDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd" // Customize the date format as needed
    let currentDate = Date()
    let dateString = dateFormatter.string(from: currentDate)

    return dateString
}
