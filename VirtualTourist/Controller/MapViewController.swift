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
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // creating and deleting new
//        let locationToDelete = Location(context: dataController.viewContext)
//        locationToDelete.lat = (view.annotation?.coordinate.latitude)!
//        locationToDelete.lon = (view.annotation?.coordinate.longitude)!
        //dataController.viewContext.delete(locations[0])
        if let locationToDelete = locationFromAnotation(anotation: view.annotation!){
          dataController.viewContext.delete(locationToDelete)
        }
        
        //try? dataController.viewContext.save()
        do {
            try dataController.viewContext.save()
        } catch let error {
            print(error)
        }
        loadLocations()
    }
    func locationFromAnotation(anotation: MKAnnotation) -> Location? {
        for location in locations{
            if location.lat == anotation.coordinate.latitude && location.lon == anotation.coordinate.longitude{
                return location
            }
        }
        return nil
    }

}

