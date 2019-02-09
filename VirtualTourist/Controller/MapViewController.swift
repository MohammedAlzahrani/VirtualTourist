//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Mohammed ALZAHRANI on 08/02/2019.
//  Copyright © 2019 Mohammed ALZAHRANI. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var dataController: DataController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.mapView.delegate = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressRecognizer.minimumPressDuration = 1
        self.mapView.addGestureRecognizer(longPressRecognizer)
    }
    @objc func longPress(longPressRecognizer: UILongPressGestureRecognizer){
        print("long pressed")
        let longPressedPoint = longPressRecognizer.location(in: mapView)
        let coordinate = mapView.convert(longPressedPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    

}

