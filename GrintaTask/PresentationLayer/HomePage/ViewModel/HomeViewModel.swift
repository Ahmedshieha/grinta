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
        self.dataSource = self.dataSource.sorted(by: {$0.date < $1.date}).filter({$0.date >= getCurrentDate()})
    }
    
    
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Customize the date format as needed
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)

        return dateString
    }

    
    
}


