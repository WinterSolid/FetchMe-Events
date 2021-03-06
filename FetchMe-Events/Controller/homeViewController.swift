//
//  homeViewController.swift
//  FetchMe-Events
//
//  Created by Zakee Tanksley on 9/26/21.
// client ID is for Seatgeek API

import Foundation
import UIKit
import CoreData
import CoreLocation

//  Home screen Controller
class homeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate {
    
    private var events = Events(events: [])
    private var recommendations = Recommendations(recommendations: [])
    private var favoritedEvents: [NSManagedObject] = []
    private var selectedIndex: Int!
    private var latitude: String = ""
    private var longitude: String = ""
    
    var locationManager: CLLocationManager = CLLocationManager()
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    // Client ID API
    private let clientID = "MjM2MTA4NTN8MTYzMjg0MDAwMS43Nzc4NTk"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tableview Setup
        tableView.delegate = self
        tableView.dataSource = self
        
        // Searchbar Setup
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavoritedEventIDs()
        
        // Ensures back button maintains same events as search
        if (favoritedEvents.count > 0 && (searchBar.text == "" || searchBar.text == nil) && latitude != "" && longitude != "") {
            getRecommendations()
        } else {
            searchEvents(url: createSearchURL(search: searchBar.text ?? ""))
        }
    }
    
    //SeatGeek API
    
    private func getEvents() {
        guard let url = URL(string: "https://api.seatgeek.com/2/events?client_id=\(clientID)") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let eventsResponse = try decoder.decode(Events.self, from: data)
                self.events = eventsResponse
                print("Found \(self.events.events.count) random events")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print("Error thrown while fetching data from SeatGeek API: \(error)")
            }
        }
        
        task.resume()
    }
    
    //Gets recommended events:
    //using user favorited events/user location
    private func getRecommendations() {
        let eventID: Int!
        
        if (favoritedEvents.count > 0 && latitude != "" && longitude != "") {
            eventID = favoritedEvents.first!.value(forKeyPath: "eventID") as? Int
            
            guard let url = URL(string: "https://api.seatgeek.com/2/recommendations?events.id=\( eventID!)&lat=\(latitude)&lon=\(longitude)&client_id=\(clientID)") else { return }
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                do {
                    // Get recommendations
                    let decoder = JSONDecoder()
                    let recommendationResponse = try decoder.decode(Recommendations.self, from: data)
                    self.recommendations = recommendationResponse
                    
                    // Replace events with new recommended events
                    var recommendedEvents = [Event]()
                    for event in self.recommendations.recommendations {
                        recommendedEvents.append(event.event)
                    }
                    self.events.events = recommendedEvents
                    print("Found \(self.events.events.count) recommended events")
                    
                    // Reload tableview
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch let error {
                    print("Error thrown while fetching data from SeatGeek API: \(error)")
                }
            }
            
            task.resume()
            
        } else {
            print("No favorited events to get recommendations. Try favoriting an event to get recommendations.")
            searchEvents(url: createSearchURL(search: searchBar.text ?? ""))
        }
    }
    
    //Favorited events
    private func getFavoritedEventIDs() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoritedEvent")
        
        do {
            favoritedEvents = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error thrown while fetching favorited events: \(error), \(error.userInfo)")
        }
    }
    
    private func getFavoritedEvents() {
        if (self.favoritedEvents.count > 0) {
            
            for event in self.favoritedEvents {
                let eventID = event.value(forKeyPath: "eventID") as? Int
                
                guard let url = URL(string: "https://api.seatgeek.com/2/events?id=\(eventID!)&client_id=\(clientID)") else { return }
                
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let data = data else { return }
                    do {
                        let decoder = JSONDecoder()
                        let eventsResponse = try decoder.decode(Events.self, from: data)
                        self.events.events.insert(eventsResponse.events.first!, at: 0)
                        print("Inserted event: \(eventsResponse.events.first!.title)")
                    } catch let error {
                        print("Error thrown while fetching data from SeatGeek API: \(error)")
                    }
                }
                
                task.resume()
            }
        }
    }
    //Search and Queries
    private func createSearchURL(search: String) -> URL {
        let query = "https://api.seatgeek.com/2/events?client_id=\(clientID)&q=\(search.replacingOccurrences(of: " ", with: "+").lowercased())"
        return URL(string: query)!
    }
    
    //Search URL
    private func searchEvents(url: URL) {
        let search = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(Events.self, from: data)
                self.events = searchResponse
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print("Error thrown while searching data from SeatGeek API: \(error)")
            }
        }
        
        search.resume()
    }
    
    // MARK: Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange search: String) {
        if (favoritedEvents.count > 0 && searchBar.text == "" && latitude != "" && longitude != "") {
            getRecommendations()
        } else {
            searchEvents(url: createSearchURL(search: search))
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    // MARK: TableView Configuration
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Clicked event: \(events.events[indexPath.row].short_title)")
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "GoToEventDetails", sender: self)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventView", for: indexPath) as! EventView
        
        if (events.events.count >= indexPath.row + 1) {
            cell.EventsViewSetup(event: events.events[indexPath.row], favoritedEventIDs: favoritedEvents)
        }

        return cell
    }
    
    // MARK: Setup of Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        
        latitude = String(first.coordinate.latitude)
        longitude = String(first.coordinate.longitude)
        print("Collected latitude/longitude for recommended events: \(latitude), \(longitude)")
        
        if (favoritedEvents.count > 0 && searchBar.text == "" && latitude != "" && longitude != "") {
            getRecommendations()
        }
    }
    
    //Segue Setup
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToEventDetails"
        {
            if let vc = segue.destination as? detailViewController
            {
                vc.selectedEvent = events.events[selectedIndex]
            }
        }
    }
    
    // Clear Database in Emergencies
    private func deleteAll() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoritedEvent")
        fetchRequest.includesPropertyValues = false

        do {
            let items = try managedContext.fetch(fetchRequest) as! [NSManagedObject]

            for item in items {
                managedContext.delete(item)
            }
            
            try managedContext.save()
        } catch let error {
            print("Error cleaning database: \(error)")
        }
    }
}
