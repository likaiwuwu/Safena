//
//  NotifyViewControllerDelegate.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/3/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import UIKit
import Foundation

extension NotifyViewController: UITableViewDelegate {
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BystanderTableViewCell", for: indexPath) as! BystanderTableViewCell
        let user = userList[indexPath.row]
        
        cell.nameLabel.text = user.name.getFullName()
        let distance = fakeUser.location.distance(from: user.location)
        cell.distanceLabel.text = String("\(distance.rounded(.up))m")
        
        return cell
    }
    
    
}
