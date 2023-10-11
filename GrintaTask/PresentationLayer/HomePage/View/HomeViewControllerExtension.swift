//
//  HomeViewControllerExtension.swift
//  GrintaTask
//
//  Created by Ahmed Reda on 11/10/2023.
//

import Foundation
import UIKit

extension HomeViewController {

    func selectButton(type : ButtonSelection) {
        switch type {
        case .list:
            listLabel.textColor = .hex("#47B2B3")
            listUnderLine.backgroundColor = .hex("#47B2B3")
            favoriteLabel.textColor = .hex("#8D929A")
            favoriteUnderLine.backgroundColor = .hex("#E9E9E9")
           
        case .favorite:
            favoriteLabel.textColor = .hex("#47B2B3")
            favoriteUnderLine.backgroundColor = .hex("#47B2B3")
            listLabel.textColor = .hex("#8D929A")
            listUnderLine.backgroundColor = .hex("#E9E9E9")
        }
  
    }
}


