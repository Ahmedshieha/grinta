//
//  HomeViewModel.swift
//  GrintaTask
//
//  Created by Ahmed Reda on 11/10/2023.
//

import Foundation


class HomeViewModel {
    
    @Published @MainActor var state : ScreenState<Void> = .ideal
    
    var matches : [Match] = []
    
    var dataSource = [Section]()
    private let manager = HomeNetworkManager()
    var bag = AppBag()
    
    var grouped = Dictionary<String, [Match]>()
    
    
    @MainActor
    func getMatches () async {
        state = .loading
        manager.getMatches { [weak self] result  in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                guard let matches = data.matches else {return}
                self.matches = matches
                self.setSections()
                self.state = .success(())
            case .failure(let error):
                self.state = .failure(error.localizedDescription)
            }
        }
    }

    func setSections () {
        self.matches.forEach { match in
            if !self.dataSource.contains(where: {$0.date.prefix(10) == match.utcDate?.prefix(10)}) {
                self.dataSource.append(Section(date: String(match.utcDate?.prefix(10) ?? ""), matches: [match]))
            } else {
                guard let index = self.dataSource.firstIndex(where: {$0.date == match.utcDate}) else {return}
                self.dataSource[index].matches.append(match)
            }
        }
    }
 
    
    
    class Section  {
        var date: String
        var matches: [Match]
        
        init(date: String, matches: [Match]) {
            self.date = date
            self.matches = matches
        }
    }
    
}
