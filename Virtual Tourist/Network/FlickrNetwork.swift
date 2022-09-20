//
//  FlickrNetwork.swift
//  VirtualTourist
//
//  Created by Deborah on 2/13/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation

class FlickrNetwork {
    private static let flickrEndpoint  = "https://api.flickr.com/services/rest/"
    private static let flickrAPIKey    = "f854d949eca9300dc3219135d702ab3a"
    private static let flickrSearch    = "flickr.photos.search"
    private static let format          = "json"
    private static let searchRangeKM   = 10
    
    //Get Images
    
    static func getFlickrImages(lat: Double, lng: Double, page: Int = 1, completion: @escaping (FlickerSearchResponse?, Error?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "\(flickrEndpoint)?method=\(flickrSearch)&format=\(format)&api_key=\(flickrAPIKey)&lat=\(lat)&lon=\(lng)&page=\(page)&radius=\(searchRangeKM)")!)
        getRequest(url: request.url!, responseType: FlickerSearchResponse.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func getRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            let range = Range(uncheckedBounds: (14, data!.count - 1))
            let newData = data?.subdata(in: range)
            guard let newData = newData else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func downloadImage(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let download = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        download.resume()
    }
}
