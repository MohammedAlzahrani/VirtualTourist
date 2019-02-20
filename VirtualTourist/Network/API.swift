//
//  API.swift
//  VirtualTourist
//
//  Created by Mohammed ALZAHRANI on 10/02/2019.
//  Copyright © 2019 Mohammed ALZAHRANI. All rights reserved.
//

import Foundation

class API {
    static let sharedAPI = API()
    
    // return urls of photos
    func getPhotosURLs(lat:Double, lon: Double, completion: @escaping (_ result:[URL]?, _ error:String?)->Void)  {
        // constructing the url
        let latString = String(lat)
        let lonString = String(lon)
        let urlString = APIConstants.PhotoSearchURL + "&lat=" + latString + "&lon=" + lonString
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            // error handling
            func sendError(_ error: String) {
                print(error)
                completion(nil, error)
            }
            guard  (error == nil) else {
                sendError("There was an error with your request")
                return
            }
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {
                sendError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            var urls:[URL] = []
            let photosDict = parsedResult["photos"] as! [String:AnyObject]
            /* GUARD: Was there any photos returned for that location? */
            guard (photosDict["total"] as! String != "0") else{
                sendError("No photo was found for this location")
                return
            }
            let photoArray = photosDict["photo"] as! [[String: AnyObject]]

            for _ in 1...12{
                let randomNumber = Int(arc4random_uniform(UInt32(photoArray.count)))
                let urlString = photoArray[randomNumber]["url_m"] as! String
                urls.append(URL(string: urlString)!)
            }
            
            completion(urls, nil)
        }
        task.resume()
    }
}
