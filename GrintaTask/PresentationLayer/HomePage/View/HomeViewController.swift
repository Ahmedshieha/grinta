//
//  HomeViewController.swift
//  GrintaTask
//
//  Created by Ahmed Reda on 11/10/2023.
//

import UIKit

enum ButtonSelection {
    case list
    case favorite
    
}

class HomeViewController: BaseController {
    
    
    @IBOutlet weak var matchesTableView: UITableView!
    @IBOutlet weak var listViewButton: ViewWithButtonEffect!
    @IBOutlet weak var favoriteViewButton: ViewWithButtonEffect!
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var listUnderLine: UIView!
    @IBOutlet weak var favoriteUnderLine: UIView!
    
    var vm = HomeViewModel()
    var buttonSelected : ButtonSelection = .list
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        setupButtons()
        setupTableView()
        getData()
        
    }
    
    func setupTableView() {
        matchesTableView.delegate = self
        matchesTableView.dataSource = self
        matchesTableView.register(cellType: MatchesTableViewCell.self)
    }
    
    
    func setupButtons() {
        selectButton(type: .list)
        listViewButton.target  = {
            self.buttonSelected = .list
            self.updateButtonBackgroung()
            self.resetData()
        }
        favoriteViewButton.target  = {
            self.buttonSelected = .favorite
            self.updateButtonBackgroung()
            self.vm.dataSource = []
            self.matchesTableView.reloadData()
           
        }
    }
    
    func getData () {
        Task {
            await self.vm.getMatches()
        }
    }
    
    func resetData() {
        vm.dataSource = []
        matchesTableView.reloadData()
        getData()
    }
    
    func updateButtonBackgroung() {
        switch buttonSelected {
        case.list :
            selectButton(type: .list)
            
        case.favorite :
            selectButton(type: .favorite)
        }
        matchesTableView.reloadData()
    }
}

extension HomeViewController  {
    
    func subscribe() {
        vm.$state.sink { [weak self] state in
            guard let self = self else {return}
            self.handleState(state)
        }.store(in: &bag)
    }
    
    func handleState (_ state : ScreenState<Void>) {
        switch state {
        case .ideal:
            stopLoading()
        case .loading:
            startLoading()
        case .success(_):
            matchesTableView.reloadData()
            stopLoading()
        case .failure(let error):
            showAlert(with: error)
        }
    }
}


extension HomeViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.dataSource[section].matches.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return vm.dataSource[section].date
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        vm.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: MatchesTableViewCell.self, for: indexPath)
        cell.configCell(match: vm.dataSource[indexPath.section].matches[indexPath.row])
        cell.selectionStyle = .none
        cell.addFav = { [weak self] in
            guard let self else {return}
            if let favourite = self.vm.dataSource[indexPath.section].matches[indexPath.row].favorite, favourite == true {
                self.vm.dataSource[indexPath.section].matches[indexPath.row].favorite = false
                self.vm.deleteId(id: self.vm.dataSource[indexPath.section].matches[indexPath.row].id ?? 0)
            } else {
                self.vm.dataSource[indexPath.section].matches[indexPath.row].favorite = true
                self.vm.saveId(id: self.vm.dataSource[indexPath.section].matches[indexPath.row].id ?? 0)
            }
            tableView.reloadRows(at: [indexPath], with: .none)
            
        }
        return cell
    }
    
   
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.lightGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black
        header.layer.cornerRadius = 10
        header.layer.masksToBounds = true
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
        
    }

        
    }
  
    


