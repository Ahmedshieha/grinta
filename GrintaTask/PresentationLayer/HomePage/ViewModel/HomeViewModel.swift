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
 
    func setSections()  {
        let daytransactions = Dictionary(grouping: matches) { (list) -> String.SubSequence in
            return list.utcDate?.prefix(10) ?? ""
        }
        self.dataSource =  daytransactions.map { (key , value) in
            return Section(date: String(key), matches: value)
        }
        self.dataSource = self.dataSource.sorted(by: {$0.date < $1.date})
       
        
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

extension String {
    func getDateAsDate () -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = self
        guard let date = dateFormatter.date(from: self) else { return Date() }
        return date
    }
    
}
