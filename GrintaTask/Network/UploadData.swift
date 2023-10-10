//
//  UploadData.swift
//  SaudiMarch
//
//  Created by Youssef on 19/10/2022.
//  Copyright © 2022 Youssef. All rights reserved.
//

import SwiftUI

protocol UploadDataProtocol {
    var data: Data { get set }
    var fileName: String { get set }
    var mimeType: String { get set }
    var name: String { get set }
}

struct UploadData: UploadDataProtocol {
    var data: Data
    var fileName: String
    var mimeType: String
    var name: String
    
    init(imageData: Data, name: String = "file") {
        self.data = imageData
        self.name = name
        self.fileName = "\(name).jpeg"
        self.mimeType = "\(name)/jpeg"
    }
    
    init(image: UIImage, name: String = "file") {
        self.data = image.jpegData(compressionQuality: 0.4)!
        self.name = name
        self.fileName = "\(name).jpeg"
        self.mimeType = "\(name)/jpeg"
    }
    
    init?(image: UIImage?, name: String?) {
        if let image = image, let name = name {
            self.data = image.jpegData(compressionQuality: 0.4)!
            self.name = name
            self.fileName = "\(name).jpeg"
            self.mimeType = "\(name)/jpeg"
        } else {
            return nil
        }
    }
}
