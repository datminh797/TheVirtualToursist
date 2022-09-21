//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Minhdat on 20/09/2022.
//

import Foundation
import UIKit
import MapKit
import CoreImage

class PhotoViewController: UIViewController, UICollectionViewDelegateFlowLayout, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pinned: Pin?
    var coreDataService: CoreDataService?
    var photos: [Photo]?
    var page: Int = 0
    var totalImage: Int = 0
    var photo: PhotoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupMapView()
        setupCollectionView()
        reloadPhotos()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        page = 1
        self.getPhoto()
    }
    
    func setupCollectionView() {
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = flowLayout
    }
    
    func reloadPhotos(){
        photos = pinned?.relationshipPhoto?.allObjects as? [Photo]
        collectionView.reloadData()
    }
    
    func setupMapView() {
        mapView.delegate = self
        
        let annotation = MKPointAnnotation()
               
        let cordinate = CLLocationCoordinate2D(latitude: pinned?.latitude ?? 0, longitude: pinned?.longitude ?? 0)
        annotation.coordinate = cordinate
        
        mapView.addAnnotation(annotation)
        
        mapView.showAnnotations([annotation], animated: true)
        
        mapView.selectAnnotation(annotation, animated: true)
        
        let rectangleSide = 5000
        let region = MKCoordinateRegion( center: cordinate, latitudinalMeters: CLLocationDistance(exactly: rectangleSide)!, longitudinalMeters: CLLocationDistance(exactly: rectangleSide)!)
        
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }

    @IBAction func newCollectionAction(_ sender: Any) {
        page = Int(arc4random_uniform(UInt32(self.totalImage / (self.photo?.pages ?? 6))))
        getPhoto()
    }
    
    func getPhoto() {
        FlickrNetwork.getFlickrImages(lat: pinned?.latitude ?? 0.0, lng: pinned?.longitude ?? 0.0, page: page, completion: photoSearchResponse(response:error:))
    }
    
    func photoSearchResponse(response: FlickerSearchResponse?, error: Error?) -> Void {
        try? CoreDataService.sharedInstance().viewContext.delete

        if let response = response {
            pinned?.relationshipPhoto = []
            self.photo = response.photos
            if let arrayImage = response.photos?.photo {
                for image in arrayImage {
                    if let imageId = image.id {
                        let newPhoto = Photo(context: CoreDataService.sharedInstance().viewContext)
                        newPhoto.id = imageId
                        newPhoto.url = URL(string: image.imageURLString())
                        self.pinned?.addToRelationshipPhoto(newPhoto)
                        try? CoreDataService.sharedInstance().viewContext.save()
                    }
                }
                totalImage += arrayImage.count
            }
            reloadPhotos()
        }
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
}

extension PhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3 - 5
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as? PhotoCollectionCell, let photo = photos?[(indexPath as NSIndexPath).row] else {
            return UICollectionViewCell()
        }
        cell.setup(photo: photo)
        cell.photoCellImage.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        if let photo = photos?[(indexPath as NSIndexPath).row] {
            CoreDataService.sharedInstance().viewContext.delete(photo)
            try? CoreDataService.sharedInstance().viewContext.save()
        }
        reloadPhotos()
    }
}