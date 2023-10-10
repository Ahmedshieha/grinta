//
//  HomeViewModel.swift
//  GrintaTask
//
//  Created by Ahmed Reda on 11/10/2023.
//

import Foundation


class HomeViewModel {
    
    @Published @MainActor var state : ScreenState<[Match]> = .ideal
    
    private let manager = NetworkManager()
    var bag = AppBag()
    
    
    
    
    @MainActor
    func getMatches () async {
        state = .loading
        manager.getMatches { [weak self] result  in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                guard let matches = data.matches else {return}
                self.state = .success(matches)
            case .failure(let error):
                self.state = .failure(error.localizedDescription)
            }
        }
    }
    
    
    
}
