//
//  Identifier.swift
//  Ichan
//
//  Created by Cédric Rolland on 28.05.18.
//  Copyright © 2018 Cédric Rolland. All rights reserved.
//

import UIKit

extension UIViewController {
    class var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell {
    class var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell {
    class var identifier: String {
        return String(describing: self)
    }
}
