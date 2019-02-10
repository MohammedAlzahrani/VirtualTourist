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
    // TODO:- return urls of photos
    func getStudentLocations(lat:Double, lon: Double, completion: @escaping (_ success:Bool?, _ error:String?)->Void)  {
        let latString = String(lat)
        let lonString = String(lon)
        let urlString = APIConstants.PhotoSearchURL + "&lat=" + latString + "&lon=" + lonString
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            func sendError(_ error: String) {
                print(error)
                completion(false, error)
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
            print(String(data: data, encoding: .utf8)!)
            var photosDict: [String:Any]
            do{
                locationsDict = try JSONDecoder().decode(jsonResponse.self, from: data)
            } catch let jsonError{
                sendError(jsonError.localizedDescription)
                print("json error")
                print(jsonError)
                return
            }
            self.appDelegate.studentLocations = locationsDict.results
            print(locationsDict.results)
            completion(true, nil)
        }
        task.resume()
    }
}
