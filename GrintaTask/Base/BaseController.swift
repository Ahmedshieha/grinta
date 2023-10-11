//
//  BaseController.swift
//  GrintaTask
//
//  Created by Ahmed Reda on 11/10/2023.
//

import Foundation

import UIKit
import NVActivityIndicatorView

protocol BaseViewProtocol: AnyObject {
    var activityIndicatorView: NVActivityIndicatorView { get }
    
    func startLoading()
    func stopLoading()
    func showAlert(with message: String)
}


class BaseController: UIViewController, BaseViewProtocol {
   
    
    
    lazy var activityIndicatorView = NVActivityIndicatorView(frame: .init(x: 0, y: 0, width: 80, height: 80), type: .ballClipRotate, color: .gray, padding: .zero)
    
    var bag = AppBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let vc = self.navigationController?.viewControllers.first
//        if vc == self.navigationController?.visibleViewController {
//            //Code Here
//            print("root")
//        } else {
//            setNavigationItem()
//        }
    }
    
    func handleScreenState<T>(_ state: ScreenState<T>) {
        switch state {
        case .ideal:
            self.stopLoading()
        case .loading:
            self.startLoading()
        case .success(_):
            self.stopLoading()
        case .failure(let error):
            self.showAlert(with: error)
            self.stopLoading()
        }
 
    }

}

extension BaseViewProtocol  where Self : UIViewController{
    
    func startLoading() {
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = UIScreen.main.bounds.center
        activityIndicatorView.startAnimating()
    }
    
    func stopLoading() {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
    }
    
    func showAlert(with message: String) {
        print(message)
    }
}


extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
