//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Minhdat on 20/09/2022.
//

import UIKit
import MapKit
import CoreData

class TravelAnnotation: MKPointAnnotation {
    var pinned: Pin?
}

class MapViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var coreData: CoreDataService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Virtual Tourist"
        coreData = CoreDataService.sharedInstance()
        CoreDataService.sharedInstance().fetchedData(self)
        setTheMap()
        loadThePin()
    }
    
    func setTheMap(){
        mapView.delegate = self
        let centerCoordinate = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "Latitude"), longitude: UserDefaults.standard.double(forKey: "Longitude"))
        let latitudeDelta = UserDefaults.standard.double(forKey: "LatitudeDelta")
        let longitudeDelta = UserDefaults.standard.double(forKey: "LongitudeDelta")
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion( center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let pin = savePin(coordinate: coordinate)
            let annotation = TravelAnnotation()
            annotation.coordinate = coordinate
            annotation.pinned = pin
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func savePin(coordinate: CLLocationCoordinate2D) -> Pin {
        let pin = Pin(context: CoreDataService.sharedInstance().viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        do {
          try CoreDataService.sharedInstance().viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        return pin
    }

    func loadThePin(){
        if let locations = CoreDataService.sharedInstance().fetchedData?.fetchedObjects {
            var annotations = [TravelAnnotation]()
                    
            for dictionary in locations {
                let lat = CLLocationDegrees(dictionary.latitude)
                let long = CLLocationDegrees(dictionary.longitude)
                
                let cordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let annotation = TravelAnnotation()
                annotation.coordinate = cordinate
                annotation.pinned = dictionary
                
                annotations.append(annotation)
            }

            mapView.addAnnotations(annotations)
        }
    }
}

extension MapViewController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "Latitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "Longitude")
        let zoom = mapView.region.span
        UserDefaults.standard.set(zoom.latitudeDelta, forKey: "LatitudeDelta")
        UserDefaults.standard.set(zoom.longitudeDelta, forKey: "LongitudeDelta")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .systemTeal
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        let annotation = view.annotation as? TravelAnnotation
        guard let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController else {
            return
        }
        vc.pinned = annotation?.pinned
//        vc.coreDataService = coreData!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
