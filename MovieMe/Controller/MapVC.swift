//
//  MapController.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var dataManager: ApiMediaManagerProtocol?
    private var theatersList: [MovieTheaterResult] = [MovieTheaterResult]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        self.dependencyInjection()
        self.getData()
    }

    private func dependencyInjection() {
        let dataManager = DataManager(delegate: self)
        self.dataManager = dataManager
    }
    
    private func getData() {
        self.dataManager?.fetchMovieTheaters(url: MOVIE_THEATERS_API_URL, completion: { (movieTheater) in
            
            guard let theater = movieTheater else { return }
            let movieTheaters = self.dataManager?.fetchMovieResultsIntoTheaters(theatersResult: theater)
            guard let movieThea = movieTheaters else { return }
            for item in movieThea {
                self.theatersList.append(item)
            }
            
            DispatchQueue.main.async {
                for theater in self.theatersList {
                    let annotation = MKPointAnnotation()
                    annotation.title = theater.name
                    annotation.subtitle = theater.location.address
                    annotation.coordinate = CLLocationCoordinate2D(latitude: theater.location.lat ?? 0.0, longitude: theater.location.lng ?? 0.0)
                    self.mapView.addAnnotation(annotation)
                }
            }
        })
    }
}

// MARK: ControllerInput Methods

extension MapVC: ControllerInput {
    func handleError(error: Error) {
        
    }
}

// MARK: MKMapViewDelegate Methods

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.rightCalloutAccessoryView = UIButton(type: .contactAdd)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = UIImage(named: "pin40")
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
//        view.bottomAnchor.constraint(equalTo: (tabBarController?.tabBar.topAnchor)!, constant: 0).isActive = true
        
        self.view.addSubview(view)
    }
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
//        renderer.strokeColor = UIColor.systemBlue
//        return renderer
//    }
}

