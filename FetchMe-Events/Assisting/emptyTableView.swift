//
//  emptyTableView.swift
//  FetchMe-Events
//
//  Created by Zakee Tanksley on 9/25/21.
//
import UIKit
import Foundation

extension UITableView {
    
    
    func setEmptyMessage(_ message: String, view: UIView) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0,
                            width: self.bounds.size.width,
                            height: self.bounds.size.height))
        
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .black
        messageLabel.font = UIFont(name: "Menlo", size: 15)
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        self.backgroundView = view
        self.separatorStyle = .none
    }

// Restore tableview components to default
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
