//
//  PhotosResponse.swift
//  VirtualTourist
//
//  Created by Mohammed ALZAHRANI on 10/02/2019.
//  Copyright © 2019 Mohammed ALZAHRANI. All rights reserved.
//

import Foundation

struct PhotosResponse: Codable {
    var photos: [PhotoResponse]
}

struct PhotoResponse: Codable {
    var url_m:String
}
