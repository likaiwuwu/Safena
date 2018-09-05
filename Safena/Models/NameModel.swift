//
//  NameModel.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/3/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import Foundation

class NameModel {
    
    var firstName: String
    var lastName: String
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    init() {
        self.firstName = ""
        self.lastName = ""
    }
    
    func name() -> String {
        return "\(firstName) \(lastName)"
    }
}
