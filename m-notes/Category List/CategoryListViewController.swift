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

    @IBOutlet weak var noCategoriesView: UIView!
    @IBOutlet weak var categoryListTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var loadingBackgroundView: UIView!
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
    
    fileprivate func presentCategoryViewController(withCategory category: PFObject) {
        let storyboard = UIStoryboard(name: "Category", bundle: nil)
        let orderConfirmationNC = storyboard.instantiateViewController(withIdentifier: "CategoryNC") as! UINavigationController
        let categoryVC = orderConfirmationNC.viewControllers[0] as! CategoryViewController
        categoryVC.category = category
        categoryVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(categoryVC, animated: true)
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
            let ac = UIAlertController(title: "unable to retrieve categories", message: "Please check your Internet connection and try again.", preferredStyle: .alert)
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
                let categoryIds = categories.compactMap { $0.objectId }
                let query = PFQuery(className: "Category")
                query.whereKey("objectId", containedIn: categoryIds)
                query.order(byDescending: "updatedAt")
                query.findObjectsInBackground() { (results: [PFObject]?, error: Error?) in
                    self.stopLoadingViewAnimation()
                    if results == nil || error != nil {
                        print("Parse: Error retrieving categories for current user -", error?._code as Any, "-", error?.localizedDescription as Any)
                        presentOrdersRetrievalErrorAlert(withCompletion: {
                            self.retrieveOrdersForCurrentUser(withCompletion: completion)
                        })
                    } else {
                        print("Parse: Found", results!.count, "categories:", results!)
                        self.categories = results!
                        completion?()
                    }
                }
            }
        }
    }
}

// MARK: - Table View Delegate

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentCategoryViewController(withCategory: self.categories[indexPath.row])
    }
}

// MARK: - Table View Data Source

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = self.categories.count
        
        let noCategories = numberOfRows == 0
        if noCategories {
            self.noCategoriesView.alpha = 0
            self.noCategoriesView.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
                self.noCategoriesView.alpha = 1
            })
            self.categoryListTableView.separatorStyle = .none
        } else {
            self.noCategoriesView.isHidden = true
        }
        
        return numberOfRows
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
