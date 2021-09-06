//
//  ViewController.swift  to EventView
//  FetchMe-Events
//
//  Created by Zakee T on 8/31/21.
//

import UIKit
import Foundation
import CoreData
//representation of single cell view
class EventView: UITableViewCell {
    
    @IBOutlet var eventImage: UILabel!
    
    @IBOutlet var favoriteHeartImage!
    
    @IBOutlet var eventLabel: UILabel!
    
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var dateTimeLabel: UILabel!
    
    
    func EventsViewConstruct (event: Event, favoritedEventIDs: [NSManagedObject]){
        
        eventLabel.text = event.title
        locationLabel.text = event.locationFormat()
        dateTimeLabel.text = event.formatDateTime()
        
        eventImage.loadImage(from: event.performers.first!.image!)
        
        var favorited = false
        for eventID in favoritedEventIDs {
            if eventID.value(forKeyPath: "eventID") as? Int == event.id {
                favorited = true
            }
        }
        if #available(iOS 13.0, *) {
            favoriteHeartImage.image = UIImage(systemName: "heart.fill")
        } else {
            favoriteHeartImage.image = UIImage(named: "Heart-Fill")//Early Vers.
        }
        if !favorited {
            favoriteHeartImage.isHidden = true
        }
        else {
            favoriteHeartImage.isHidden = false
        }
        func roundImageCorners() {
            eventImage.layer.cornerRadius = 7.0 //8.0
            eventImage.clipsToBounds = true
        }
        
        func setupWordWrapping() {
            eventLabel.numberOfLines = 0
            locationLabel.numberOfLines = 0
            dateTimeLabel.numberOfLines = 0
        }
        
        override func layoutSubview() {
            super.layoutSubviews()
            roundImageCorners()
        }
    }
