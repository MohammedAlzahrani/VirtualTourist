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
    var pins: [Pin] = []
    var annotations: [MKPointAnnotation] = []
    var dataController: DataController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.mapView.delegate = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.mapView.addGestureRecognizer(longPressRecognizer)
        fetchPins()

    }
    @objc func longPress(longPressRecognizer: UILongPressGestureRecognizer){
        if longPressRecognizer.state == UIGestureRecognizer.State.ended{
            print("long pressed")
            let longPressedPoint = longPressRecognizer.location(in: mapView)
            let coordinate = mapView.convert(longPressedPoint, toCoordinateFrom: mapView)

            savePin(lat: coordinate.latitude, lon: coordinate.longitude)
        }
        
    }
     func fetchPins() {
        // fetch pins from DB
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pins = result
            loadPins()
        }
    }
    func savePin(lat:Double,lon:Double) {
        print(lat)
        print(lon)
        let pin = Pin(context: dataController.viewContext)
        pin.lat = lat
        pin.lon = lon
        try? dataController.viewContext.save()
        pins.append(pin)
        loadPins()
    }
    // create annotations using pin and display it on map
    func loadPins() {
        guard pins.count != 0 else {
            print("no pins")
            return
        }
        for pin in pins{
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.lat
            annotation.coordinate.longitude = pin.lon
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        let pin = pinFromAnotation(anotation: view.annotation!)
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let photosVC = storyboard.instantiateViewController(withIdentifier: "PhotosCollectionView")as! PhotosCollectionViewController
        photosVC.dataController = dataController
        photosVC.pin = pin!
        self.navigationController?.pushViewController(photosVC, animated: true)
        
    }
    // get the pin corosponding to the selected annotation
    func pinFromAnotation(anotation: MKAnnotation) -> Pin? {
        for pin in pins{
            if pin.lat == anotation.coordinate.latitude && pin.lon == anotation.coordinate.longitude{
                return pin
            }
        }
        return nil
    }


}

