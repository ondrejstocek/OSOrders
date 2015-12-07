//
//  OrderListViewController.swift
//  OSOrders
//
//  Created by Ondřej Štoček on 01.12.15.
//  Copyright © 2015 Ondrej Stocek. All rights reserved.
//

import UIKit

import PromiseKit

class OrderListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var contact: Contact!
    var orders: [Order] = []
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var phoneLabel: UILabel!
    
    lazy var refreshControl: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        return refreshControl
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.addSubview(self.refreshControl)
        
        self.navigationItem.title = self.contact?.name
        self.phoneLabel.text = self.contact?.phone
        
        self.refresh()
    }
    
    // MARK: - Table View Data Source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OrderCell", forIndexPath: indexPath) as! OrderCell
        cell.order = self.orders[indexPath.row]
        return cell;
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    // MARK: - Actions
    
    func refresh() {
        self.orders = self.apiCommunicator.orders(contactId: self.contact.id)
        
        if !self.refreshControl.refreshing && self.orders.count == 0 {
            self.refreshControl.beginRefreshing()
            self.tableView.setContentOffset(CGPointMake(0, -self.refreshControl.frame.size.height), animated: true)
        }
        
        self.apiCommunicator.loadOrders(contact: self.contact)
            .then { [weak self] orders -> Void in
                self?.orders = orders
                self?.tableView.reloadData()
            }
            .always { [weak self] in
                self?.refreshControl.endRefreshing()
            }
            .error { [weak self] error in
                self?.showError(error)
            }   
    }
}
