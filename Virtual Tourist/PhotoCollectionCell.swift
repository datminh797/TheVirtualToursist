//
//  PhotoCollectionCell.swift
//  Virtual Tourist
//
//  Created by Minhdat on 20/09/2022.
//

import Foundation
import UIKit
class PhotoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var photoCellImage: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    func setup(photo: Photo) {
        self.indicatorView.startAnimating()
        if let imageData = photo.image {
            DispatchQueue.main.async {
                self.photoCellImage.image = UIImage(data: imageData)
                self.indicatorView.stopAnimating()
            }
        } else {
            self.downloadImage(photo: photo)
        }
    }
    
    func downloadImage(photo: Photo) {
        URLSession.shared.dataTask(with: photo.url!, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    self.photoCellImage.image = downloadedImage
                    self.indicatorView.stopAnimating()
                    photo.image = data
                    try? CoreDataService.sharedInstance().viewContext.save()
                }
            }

        }).resume()
    }
}
