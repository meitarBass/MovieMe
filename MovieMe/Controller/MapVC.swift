//
//  MapController.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import CoreLocation

class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cinemaSearchBar: CustomSearchBar!
    @IBOutlet weak var theaterDataView: CustomMovieTheaterView!
    
    private let locationManager = CLLocationManager()
    
    private var dataManager: LocationApiManager?
    private var realmManager: RealmManagerProtocol?
    private var geocodingManager: GeocodingApiManager?
    
    private var theaterLocation: Results<MovieTheatersNearMe>?
    
    private var theatersList: [MovieTheaterResult] = [MovieTheaterResult]()
    private var index = 0
    
    private var chosenName: String?
    private var chosenAddress: String?
    private var chosenDistance: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        cinemaSearchBar.delegate = self
        
        self.dependencyInjection()
        self.checkLocationServicesStatus()
        self.getUserLocation()
        
        self.loadData()
        DispatchQueue.main.async {
            guard let theaterLocation = self.theaterLocation else { return }
            for theater in theaterLocation {
                let venue = Venue(venue: MovieTheaterResult(name: theater.name, location: Location(address: theater.address, lat: theater.lat, lng: theater.lng, distance: theater.distance, city: theater.city)))
                self.saveNewPoints(venue: venue)
                self.setPoints(theater: venue)
            }
        }
    }

    private func dependencyInjection() {
        let dataManager = MapManager(delegate: self)
        self.dataManager = dataManager
        
        let realmManager = RealmManager(delegate: self)
        self.realmManager = realmManager
        
        let geocodingManager = GeocodingManager(delegate: self)
        self.geocodingManager = geocodingManager
    }
    
    private func getNewData(lat: String, lon: String) {
        self.dataManager?.fetchMovieTheaters(url: MOVIE_THEATERS_API_URL + lat + "," + lon + "&query=movie", completion: {[weak self] (movieTheater) in
            guard let movieTheater = movieTheater else { return }
            DispatchQueue.main.async {
                for theater in movieTheater {
                    guard let wasPointsSaved = self?.saveNewPoints(venue: theater) else { return }
                    if wasPointsSaved {
                        self?.setPoints(theater: theater)
                    }
                }
            }
        })
    }
}

// MARK: ControllerInput Methods

extension MapVC: ControllerInput {
    func handleError(error: Error) {
        self.presentAlert(title: "error", err: error.localizedDescription, errType: nil)
    }
}

// MARK: MKMapViewDelegate Methods

extension MapVC: MKMapViewDelegate {
    
    // Create annotation on map
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        let annotationIdentifier = "AnnotationIdentifier"
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView.annotation = annotation
            return annotationView
        } else {
            return MovieTheaterAnnotation(annotation: annotation, reuseIdentifier:
                annotationIdentifier)
        }
    }
    
    // Annotation was selected
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MovieTheaterPoint {
            self.chosenName = theatersList[annotation.index].name
            self.chosenDistance = theatersList[annotation.index].location.distance
            self.chosenAddress = theatersList[annotation.index].location.address
//            self.requestDirectionsTo(location: CLLocationCoordinate2D(latitude: theatersList[annotation.index].location.lat ?? 0, longitude: theatersList[annotation.index].location.lng ?? 0))
        }
        
        theaterDataView.setLabels(name: chosenName ?? "nil", distance: chosenDistance ?? 0, address: chosenAddress ?? "")
        theaterDataView.animShow(view: self.view)
    }
    
    // Annotation was deselected
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.theaterDataView.animHide(view: self.view)
    }
}

// MARK: - CoreLocation Delegate Functions

extension MapVC: CLLocationManagerDelegate {
    
    // Get location update
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1250, longitudinalMeters: 1250)
            self.mapView.setRegion(region, animated: true)
            self.getNewData(lat: String(location.coordinate.latitude), lon: String(location.coordinate.longitude))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong with location manager")
    }
}

// MARK: Location Methods

extension MapVC {
    
    // Checking for user allowance and asking for it if hasn't yet
    
    func checkLocationServicesStatus() {
        if CLLocationManager.locationServicesEnabled() {
            checkAuthorizationStatus()
        } else {
            DispatchQueue.main.async {
                self.presentAlert(title: "Location Services", err: "Please enable location services to use this app", errType: nil)
            }
        }
    }
    
    // Check if user allowed using location
    
    func checkAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .authorizedAlways:
            mapView.showsUserLocation = true
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        case .restricted: break
        // Show alert telling users how to turn on permissions
        case .denied: break
            // Show an alert letting them know what’s up
            
        @unknown default:
            fatalError("Unknown fatal error")
        }
    }
    
    // Get user current location
    
    func getUserLocation() {
        locationManager.requestLocation()
    }
    
    
}

// MARK: Offline Mode Methods

extension MapVC {
    
    private func loadData() {
         guard let loadedData = realmManager?.loadData(modelType: MovieTheatersNearMe.self) else { return }
         theaterLocation = loadedData
     }
    
    private func setPoints(theater: Venue) {
        let annotation = MovieTheaterPoint()
        annotation.setAnnotationPoint(pointModel: theater.venue, index: self.index)
        self.theatersList.append(theater.venue)
        self.mapView.addAnnotation(annotation)
        self.index += 1
    }
    
    private func saveNewPoints(venue: Venue) -> Bool {
        let movieTheater = MovieTheatersNearMe()
        movieTheater.name = venue.venue.name
        movieTheater.address = venue.venue.location.address
        movieTheater.city = venue.venue.location.city
        movieTheater.distance = venue.venue.location.distance ?? 0
        movieTheater.lng = venue.venue.location.lng ?? 0.0
        movieTheater.lat = venue.venue.location.lat ?? 0.0
            
        let isSavedAlready = self.realmManager?.isPointSaved(lat: movieTheater.lat, lng: movieTheater.lng, modelType: MovieTheatersNearMe.self)

        if !(isSavedAlready ?? true) {
            self.realmManager?.saveData(object: movieTheater, modelType: MovieTheatersNearMe.self)
            return true
        } else {
            return false
        }
    }
}

// MARK: Route Methods

extension MapVC {
    
    // Coloring Route function
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.systemBlue
        return renderer
    }
    
    // Getting Route function
    
    func requestDirectionsTo(location: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: location, addressDictionary: nil))
        request.transportType = .walking

        let directions = MKDirections(request: request)
        mapView.removeOverlays(mapView.overlays)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                let mapEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 300, right: 40)
                
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: mapEdgeInsets, animated: true)
            }
        }
    }
    
}

// MARK: Search Methods

extension MapVC: UISearchBarDelegate {
    
    // TODO: Show a text for no search results
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        let textToSearch = text.replacingOccurrences(of: " ", with: "%20")
        geocodingManager?.fetchCity(url: CITY_URL + textToSearch, completion: { cityLocation in
            guard let lat = cityLocation.lat, let lng = cityLocation.lng else { return }
            DispatchQueue.main.async {
                let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                let region = MKCoordinateRegion(center: location, latitudinalMeters: 5000, longitudinalMeters: 5000)
                self.mapView.setRegion(region, animated: true)
            }
            self.getNewData(lat: String(lat), lon: String(lng))
        })
    }
}



