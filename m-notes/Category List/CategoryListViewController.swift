//
//  CategoryListViewController.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/26/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit
import Parse

class CategoryListViewController: UIViewController {

    @IBOutlet weak var categoryListTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    // TODO: BG VIEW
    
    fileprivate var categories = [PFObject]()
     
    override func viewDidLoad() {
        super.viewDidLoad()

        self.categoryListTableView.delegate = self
        self.categoryListTableView.dataSource = self
        self.categoryListTableView.estimatedRowHeight = 44.0
        self.categoryListTableView.rowHeight = UITableView.automaticDimension
        self.categoryListTableView.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
    }
}

// MARK: - Parse

extension CategoryListViewController {
    fileprivate func retrieveOrdersForCurrentUser(withCompletion completion: (() -> ())? = nil) {
        guard let _ = PFUser.current() else {
            print("error retrieving current user")
            return
        }
        
        func presentOrdersRetrievalErrorAlert(withCompletion completion: (() -> ())? = nil) {
            let ac = UIAlertController(title: "Unable to Retrieve Categories", message: "Please check your Internet connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            ac.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: { _ in
                completion?()
            }))
            present(ac, animated: true)
        }
        
        startLoadingViewAnimation()
        PFUser.current()!.fetchIfNeededInBackground() { (user: PFObject?, error: Error?) -> Void in
            if user == nil || error != nil {
                self.stopLoadingViewAnimation()
                print("Parse: Error fetching user object -", error?._code as Any, "-", error?.localizedDescription as Any)
                presentOrdersRetrievalErrorAlert() {
                    self.retrieveOrdersForCurrentUser(withCompletion: completion)
                }
            } else {
                guard let categories = user!["categories"] as? [PFObject] else {
                    self.stopLoadingViewAnimation()
                    return
                }
                let orderIds = orders.compactMap { $0.objectId }
                let query = PFQuery(className: "Order")
                query.whereKey("objectId", containedIn: orderIds)
                query.order(byDescending: "createdAt")
                query.findObjectsInBackground() { (results: [PFObject]?, error: Error?) in
                    self.stopLoadingViewAnimation()
                    if results == nil || error != nil {
                        print("Parse: Error retrieving orders for current user -", error?._code as Any, "-", error?.localizedDescription as Any)
                        presentOrdersRetrievalErrorAlert(withCompletion: {
                            self.retrieveOrdersForCurrentUser(withCompletion: completion)
                        })
                    } else {
                        print("Parse: Found", results!.count, "orders:", results!)
                        self.categories = results!
                        completion?()
                    }
                }
            }
        }
    }
    
    fileprivate func retrieveCoffeeShopAndPresentOrderConfirmationViewController(forOrder order: PFObject) {
        func presentCoffeeShopRetrievalErrorAlert(withCompletion completion: (() -> ())? = nil) {
            let ac = UIAlertController(title: "Unable to Retrieve Coffee Shop for Order", message: "Please check your Internet connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            ac.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: { _ in
                completion?()
            }))
            present(ac, animated: true)
        }
        
        func retrieveCoffeeShop(forOrder order: PFObject, withCompletionOnSuccess completion: ((PFObject) -> ())? = nil) {
            guard let coffeeShop = order["coffeeShop"] as? PFObject else {
                return
            }
            guard let _ = coffeeShop.objectId else {
                return
            }
            let query = PFQuery(className: "CoffeeShop")
            // startLoadingViewAnimation()
            query.getObjectInBackground(withId: coffeeShop.objectId!) { (object: PFObject?, error: Error?) in
                // self.stopLoadingViewAnimation()
                if object == nil || error != nil {
                    print("Parse: Error retrieving coffee shop object -", error?._code as Any, "-", error?.localizedDescription as Any)
                    presentCoffeeShopRetrievalErrorAlert() {
                        retrieveCoffeeShop(forOrder: order, withCompletionOnSuccess: completion)
                    }
                } else {
                    completion?(object!)
                }
            }
        }
        
        retrieveCoffeeShop(forOrder: order) { (coffeeShop: PFObject) in
            self.presentOrderConfirmationViewController(withOrder: order, forCoffeeShop: coffeeShop)
        }
    }
}

// MARK: - Table View Delegate

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        retrieveCoffeeShopAndPresentOrderConfirmationViewController(forOrder: self.orders[indexPath.row])
    }
}

// MARK: - Table View Data Source

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        cell.category = self.categories[indexPath.row]
        // cell.delegate = self
        return cell
    }
}

// MARK: - Animation

extension CategoryListViewController {
    fileprivate func startLoadingViewAnimation() {
        self.loadingView.startAnimating()
        self.loadingView.isUserInteractionEnabled = true // Block any further touches
        self.loadingBackgroundView.alpha = 0
        self.loadingBackgroundView.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
            self.loadingBackgroundView.alpha = 0.5
        }, completion: nil)
    }
    
    fileprivate func stopLoadingViewAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
            self.loadingBackgroundView.alpha = 0
        }, completion: { _ in
            self.loadingBackgroundView.isHidden = true
        })
        self.loadingView.isUserInteractionEnabled = false
        self.loadingView.stopAnimating()
    }
}
