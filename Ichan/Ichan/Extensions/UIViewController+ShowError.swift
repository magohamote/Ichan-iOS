//
//  UIViewController+ShowError.swift
//  Ichan
//
//  Created by Cédric Rolland on 29.05.18.
//  Copyright © 2018 Cédric Rolland. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: - Errors
    func showError(withMessage message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
