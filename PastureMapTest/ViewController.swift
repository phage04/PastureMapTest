//
//  ViewController.swift
//  PastureMapTest
//
//  Created by Lyle Christianne Jover on 2/6/18.
//  Copyright © 2018 Lyle Jover. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Each

enum ButtonAction {
    case startAddPasture
    case dropPin
    case savePasture
}

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var crosshairImage: UIImageView!
    
    var manager: CLLocationManager?
    var actionForButton: ButtonAction = .startAddPasture
    var regionRadius: CLLocationDistance = 1000
    var timer = Each(1).seconds
    var countdown = delay
    var pastureMapBoundaries = [CLLocationCoordinate2D]()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        
        checkLocationAuthStatus()
        mapView.delegate = self
        centerMapOnUserLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        crosshairImage.isHidden = true
        setBtnForCase(action: .startAddPasture)
    }
    
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countdown -= 1
            if self.countdown == 0 {
                self.setBtnForCase(action: .savePasture)
                return .stop
            }
            self.setBtnForCase(action: .dropPin)
            return .continue
        }
    }
    
    func restoreTimer() {
        self.countdown = delay
    }

    func centerMapOnUserLocation() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            manager?.startUpdatingLocation()
        } else{
            manager?.requestAlwaysAuthorization()
        }
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        buttonSelector(forAction: actionForButton)
    }
    
    func buttonSelector(forAction action: ButtonAction) {
        switch action {
        case .startAddPasture:
            setBtnForCase(action: .dropPin)
            crosshairImage.isHidden = false
            pastureMapBoundaries.removeAll()
            
        case .dropPin:
            crosshairImage.isHidden = false
            dropPin()
            
        case .savePasture:
            createPolyline()
            crosshairImage.isHidden = true
            pastureMapBoundaries.removeAll()
            timer.stop()
            setBtnForCase(action: .startAddPasture)
    
        }
    }
    
    func setBtnForCase(action: ButtonAction) {
        switch action {
            case .startAddPasture:
                self.addBtn.setTitle("ADD PASTURE MAP", for: .normal)
                UIView.animate(withDuration: 0.5, animations: {
                    self.addBtn.backgroundColor = UIColor.white
                })
                self.addBtn.setTitleColor(UIColor.darkGray, for: .normal)
                self.crosshairImage.isHidden = true
                self.actionForButton = .startAddPasture
        
            case .dropPin:
                self.addBtn.setTitle("DROP BOUNDARY", for: .normal)
                UIView.animate(withDuration: 0.5, animations: {
                    self.addBtn.backgroundColor = UIColor.white
                })
                self.addBtn.setTitleColor(UIColor.blue, for: .normal)
                self.actionForButton = .dropPin
        
            case .savePasture:
                self.addBtn.setTitle("SAVE PASTURE MAP", for: .normal)
                UIView.animate(withDuration: 0.5, animations: {
                    self.addBtn.backgroundColor = UIColor.red
                })
                self.addBtn.setTitleColor(UIColor.white, for: .normal)
                self.actionForButton = .savePasture
        }
    }
    
    func createPolyline() {
        let polygon = MKPolygon(coordinates: self.pastureMapBoundaries, count: self.pastureMapBoundaries.count)
        self.mapView.add(polygon)
    }

}

extension ViewController: CLLocationManagerDelegate{
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                checkLocationAuthStatus()
                if status == .authorizedAlways{
                    mapView.showsUserLocation = false
                    mapView.userTrackingMode = .follow
                }
       }
}

extension ViewController: MKMapViewDelegate{
    
    func dropPin() {
        let boundaryCoordinate: CLLocationCoordinate2D = self.mapView.centerCoordinate
        self.pastureMapBoundaries.append(boundaryCoordinate)
        let boundaryPlacemark = MKPlacemark(coordinate: boundaryCoordinate)
        let annotation = MKPointAnnotation()
        annotation.coordinate = boundaryPlacemark.coordinate
        self.mapView.addAnnotation(annotation)
        self.restoreTimer()
        self.setTimer()
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polygon = MKPolygonRenderer(overlay: overlay)
            polygon.strokeColor = UIColor.red
            return polygon
        }
        
        return MKPolygonRenderer()
    }
    
}




    
  

