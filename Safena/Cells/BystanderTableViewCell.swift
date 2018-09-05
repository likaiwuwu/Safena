//
//  BystanderTableViewCell.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/2/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import UIKit

class BystanderTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
