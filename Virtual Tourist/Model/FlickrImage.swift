//
//  FlickrImage.swift
//  Virtual Tourist
//
//  Created by Minhdat on 20/09/2022.
//

import Foundation
import CoreData

class FlickrImage: Codable {
    
    let id: String?
    let secret: String?
    let server: String?
    let farm: Int?
    
    init(id: String, secret: String, server: String, farm: Int) {
        
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
    }
    
    func imageURLString() -> String {
        return "https://farm\(farm ?? 0).staticflickr.com/\(server ?? "")/\(id ?? "")_\(secret ?? "")_q.jpg"
    }
}
