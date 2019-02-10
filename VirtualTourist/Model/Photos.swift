//
//  Photos.swift
//  VirtualTourist
//
//  Created by Mohammed ALZAHRANI on 10/02/2019.
//  Copyright © 2019 Mohammed ALZAHRANI. All rights reserved.
//

import Foundation

struct Photos: Codable {
    var photos: [photo]
}

struct photo: Codable {
    var url_m:String
}
