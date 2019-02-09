//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Mohammed ALZAHRANI on 08/02/2019.
//  Copyright © 2019 Mohammed ALZAHRANI. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locations: [Location] = []
    var annotations: [MKPointAnnotation] = []
    var dataController: DataController!
//    var location: Location 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.mapView.delegate = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.mapView.addGestureRecognizer(longPressRecognizer)
        // loading locations from DB
        let fetchRequest:NSFetchRequest<Location> = Location.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            locations = result
            loadLocations()
        }
    }
    @objc func longPress(longPressRecognizer: UILongPressGestureRecognizer){
        if longPressRecognizer.state == UIGestureRecognizer.State.ended{
            print("long pressed")
            let longPressedPoint = longPressRecognizer.location(in: mapView)
            let coordinate = mapView.convert(longPressedPoint, toCoordinateFrom: mapView)
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
            //mapView.addAnnotation(annotation)
            savePin(lat: coordinate.latitude, lon: coordinate.longitude)
        }
        
    }
    func savePin(lat:Double,lon:Double) {
        print(lat)
        print(lon)
        let location = Location(context: dataController.viewContext)
        location.lat = lat
        location.lon = lon
        try? dataController.viewContext.save()
        locations.append(location)
        loadLocations()
    }
    
    func loadLocations() {
        guard locations.count != 0 else {
            print("no pins")
            return
        }
        for location in locations{
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = location.lat
            annotation.coordinate.longitude = location.lon
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }

}

