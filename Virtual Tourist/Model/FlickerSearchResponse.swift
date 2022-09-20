//
//  FlickerSearchResponse.swift
//  Virtual Tourist
//
//  Created by Minhdat on 20/09/2022.
//

import Foundation
import UIKit
struct FlickerSearchResponse: Codable {
//    let stat: String
    let photos: PhotoModel?
}

struct PhotoModel: Codable {
    let page: Int?
    let pages: Int?
    let perpage: Int?
    let total: Int?
    let photo: [FlickrImage]?
}
