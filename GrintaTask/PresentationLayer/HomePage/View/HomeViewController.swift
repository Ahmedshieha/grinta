//
//  HomeViewController.swift
//  GrintaTask
//
//  Created by Ahmed Reda on 11/10/2023.
//

import UIKit

class HomeViewController: BaseController {
    
    
    private var vm = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        // Do any additional setup after loading the view.
        Task {
            await vm.getMatches()
        }
    }


}

extension HomeViewController  {
    
    func subscribe() {
        vm.$state.sink { [weak self] state in
            guard let self = self else {return}
            self.handleState(state)
        }.store(in: &bag)
    }
    
    func handleState (_ state : ScreenState<[Match]>) {
        switch state {
        case .ideal:
            stopLoading()
        case .loading:
            startLoading()
        case .success(let data):
            print(data.count)
        case .failure(let error):
            showAlert(with: error)
        }
    }
}
