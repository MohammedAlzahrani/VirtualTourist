//
//  API.swift
//  VirtualTourist
//
//  Created by Mohammed ALZAHRANI on 10/02/2019.
//  Copyright © 2019 Mohammed ALZAHRANI. All rights reserved.
//

import Foundation
import Kingfisher

class API {
    static let sharedAPI = API()
    // TODO:- return urls of photos
    func getStudentLocations(lat:Double, lon: Double, completion: @escaping (_ result:[String]?, _ error:String?)->Void)  {
        let latString = String(lat)
        let lonString = String(lon)
        let urlString = APIConstants.PhotoSearchURL + "&lat=" + latString + "&lon=" + lonString
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
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
            //print(String(data: data, encoding: .utf8)!)
//            var photos: PhotoResponse
//            do{
//                photos = try JSONDecoder().decode(PhotoResponse.self, from: data)
//            } catch let jsonError{
//                sendError(jsonError.localizedDescription)
//                print("json error")
//                print(jsonError)
//                return
//            }
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {
                sendError("Could not parse the data as JSON: '\(data)'")
                return
            }
            var urls:[String] = []
            let photosDict = parsedResult["photos"] as! [String:AnyObject]
            let photoArray = photosDict["photo"] as! [[String: AnyObject]]
            for photo in photoArray{
                urls.append(photo["url_m"] as! String)
            }
            //self.appDelegate.studentLocations = locationsDict.results
            //print(urls)
            completion(urls, nil)
        }
        task.resume()
    }
    func downloadPhotos(urls:[String], completion: @escaping (_ result:[UIImage]?, _ error:String?)->Void) {
        let downloader = ImageDownloader.default
        let url = URL(string: urls[0])!
        downloader.downloadImage(with: url) { result in
            switch result {
            case .success(let value):
                print(value.image)
                completion([value.image],nil)
            case .failure(let error):
                print(error)
                completion(nil,error.errorDescription)
            }
        }
    }
}
