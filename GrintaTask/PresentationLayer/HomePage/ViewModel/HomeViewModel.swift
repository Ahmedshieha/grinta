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
                self.matches = matches.map({ match in
                    if self.getSavedIDs().contains(match.id ?? 0) {
                        match.favorite = true
                    }
                    return match
                })
                self.state = .success(())
            case .failure(let error):
                self.state = .failure(error.localizedDescription)
            }
        }
    }
    
    func setupFavoriteLogic(at section: Int, and index: Int) {
        if let favourite = dataSource[section].matches[index].favorite, favourite == true {
            dataSource[section].matches[index].favorite = false
            deleteId(id: dataSource[section].matches[index].id ?? 0)
        } else {
            dataSource[section].matches[index].favorite = true
            saveId(id: dataSource[section].matches[index].id ?? 0)
        }
    }
    
    func reloadFavorites() {
        dataSource = dataSource.compactMap { section in
            let updatedMatches = section.matches.filter { match in
                getSavedIDs().contains(match.id ?? 0)
            }
            guard !updatedMatches.isEmpty else { return nil }
            var updatedSection = section
            updatedSection.matches = updatedMatches
            return updatedSection
        }
    }
    
    
    func getSavedIDs()-> [Int] {
        let uniqueIDs = UserDefaults.standard.array(forKey: Constants.userDefualtKey) as? [Int] ?? []
        return uniqueIDs
    }
    
    func saveId(id : Int) {
        var existingIDs = UserDefaults.standard.array(forKey: Constants.userDefualtKey) as? [Int] ?? []
        if !existingIDs.contains(id) {
            existingIDs.append(id)
            UserDefaults.standard.set(existingIDs, forKey: Constants.userDefualtKey)
            UserDefaults.standard.synchronize()
        }
    }
        
        func deleteId (id : Int) {
            if var existingIDs = UserDefaults.standard.array(forKey: Constants.userDefualtKey) as? [Int] {
                existingIDs.removeAll { $0 == id }
                UserDefaults.standard.set(existingIDs, forKey: Constants.userDefualtKey)
                UserDefaults.standard.synchronize()
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
    
    
  

    
    
}


