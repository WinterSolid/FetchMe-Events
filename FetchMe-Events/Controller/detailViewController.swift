//
//  detailViewController.swift
//  FetchMe-Events
//
//  Created by Zakee Tanksley on 9/26/21.
//

import Foundation
import UIKit
import CoreData

class detailViewController: UIViewController {

    var selectedEvent: Event!
    var favoritedEvent = false
    var favoritedEventIDs: [NSManagedObject] = []
    
    // Event information
    @IBOutlet var eventLabel: UILabel!
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var eventImage: UIImageView!
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var buyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteButtonSetup()
        backButtonSetup()
        buyButtonSetup()
        labelSetup()
        imageSetup()
        wordWrappingSetup()
    }
    
    /// Sets up favorite button on event's detail view
    private func favoriteButtonSetup() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoritedEvent")
        
        do {
            favoritedEventIDs = try managedContext.fetch(fetchRequest)
            
            for event in favoritedEventIDs {
                if event.value(forKeyPath: "eventID") as? Int == selectedEvent.id {
                    favoritedEvent = true
                }
            }
        } catch let error as NSError {
            print("Error thrown while fetching favorited events: \(error), \(error.userInfo)")
        }
        
        if (favoritedEvent) {
            // Show red heart
            favoriteButton.tintColor = UIColor.systemRed
            if #available(iOS 13.0, *) {
                favoriteButton.setImage(UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                // Fallback on earlier versions
                favoriteButton.setImage(UIImage(named: "Heart-Fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        } else {
            // Show empty heart
            if #available(iOS 13.0, *) {
                favoriteButton.tintColor = UIColor.label
            } else {
                // Fallback on earlier versions
                favoriteButton.tintColor = UIColor.black
            }
            if #available(iOS 13.0, *) {
                favoriteButton.setImage(UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                // Fallback on earlier versions
                favoriteButton.setImage(UIImage(named: "Heart")?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
    }
    
    // Adds rounded corners to buy button
    private func buyButtonSetup() {
        buyButton.layer.cornerRadius = 30
        buyButton.clipsToBounds = true
    }
    
    @IBAction func buyTicketButtonClicked() {
        if let url = URL(string: selectedEvent.url) {
            UIApplication.shared.open(url)
        }
    }
    //toggle fav/unfav
    private func toggleFavorite() {
        favoritedEvent.toggle()
        
        if (favoritedEvent) {
            // Show red heart and save changes
            print("Favorited event: \(selectedEvent.title)")
            favoriteButton.tintColor = UIColor.systemRed
            if #available(iOS 13.0, *) {
                favoriteButton.setImage(UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                // Fallback on earlier versions
                favoriteButton.setImage(UIImage(named: "Heart-Fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
            saveFavorite()
        } else {
            print("Unfavorited event: \(selectedEvent.title)")
            // Show emptyheart
            if #available(iOS 13.0, *) {
                favoriteButton.tintColor = UIColor.label
            } else {
                // Earlier versions
                favoriteButton.tintColor = UIColor.black
            }
            if #available(iOS 13.0, *) {
                favoriteButton.setImage(UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                // Earlier versions
                favoriteButton.setImage(UIImage(named: "Heart")?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
            deleteFavorite()
        }
    }
    
    @IBAction func favoriteButtonClicked() {
        toggleFavorite()
    }
    
    // Save event
    private func saveFavorite() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "FavoritedEvent", in: managedContext)!
        let favoritedEvent = NSManagedObject(entity: entity, insertInto: managedContext)
        
        favoritedEvent.setValue(selectedEvent.id, forKeyPath: "eventID")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not favorite event: \(error), \(error.userInfo)")
        }
    }
    
    // Deletes favorite event
    private func deleteFavorite() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        for event in favoritedEventIDs {
            do {
                if event.value(forKeyPath: "eventID") as? Int == selectedEvent.id {
                    managedContext.delete(event)
                    try managedContext.save()
                }
            } catch let error {
                print("Could not delete/unfavorite event: \(error)")
            }
        }
    }
    
    private func labelSetup() {
        eventLabel.text = selectedEvent.title
        dateTimeLabel.text = formatDateTime()
        locationLabel.text = locationFormat()
    }
    private func imageSetup() {
        eventImage.loadImage(from: selectedEvent.performers.first!.image!)
    }
    private func formatDateTime() -> String {
        return selectedEvent.formatDateTime()
    }
    private func locationFormat() -> String {
        return selectedEvent.locationFormat()
    }
    private func wordWrappingSetup() {
        eventLabel.numberOfLines = 0
        dateTimeLabel.numberOfLines = 0
        locationLabel.numberOfLines = 0
    }
    
    // Earlier ver
    private func backButtonSetup() {
        if #available(iOS 13.0, *) {
            backButton.setImage(UIImage(systemName: "chevron.backward")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            // Fallback on earlier versions
            backButton.setImage(UIImage(named: "Chevron-Backward")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    @IBAction func backButtonClicked() {
        self.dismiss(animated: true, completion: {})
    }
    
}
