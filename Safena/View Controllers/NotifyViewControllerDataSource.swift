//
//  NotifyViewControllerDataSource.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/3/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import UIKit
import Foundation

extension NotifyViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyUserList.count
    }    
}
