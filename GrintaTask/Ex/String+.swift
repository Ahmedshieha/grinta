//
//  String+.swift
//  GrintaTask
//
//  Created by Ahmed Reda on 11/10/2023.
//

import Foundation
extension String {
    func convertDate() -> String  {
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: self)!
        dateFormatter.dateFormat = "HH:mm a"
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
