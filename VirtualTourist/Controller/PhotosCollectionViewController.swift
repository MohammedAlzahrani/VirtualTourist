//
//  PhotosCollectionViewController.swift
//  VirtualTourist
//
//  Created by Mohammed ALZAHRANI on 08/02/2019.
//  Copyright © 2019 Mohammed ALZAHRANI. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "PhotosCollectionViewCell"

class PhotosCollectionViewController: UICollectionViewController {
    var dataController: DataController!
    var location:Location!
    var photos:[UIImage]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchPhotos()
        
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotosCollectionViewCell
        // Configure the cell
        cell.photoImageView.image = photos[indexPath.row]
        return cell
    }
    
    func fetchPhotos(){
        let photosDB:[Photo]
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            photosDB = result
            for photo in photosDB{
                photos.append(UIImage(data: photo.photo!)!)
            }
        }
    }
    func storePhotos(images:[UIImage]) {
        for image in images{
            let photo = Photo(context: dataController.viewContext)
            photo.photo = image.pngData()
        }
    }
    func downloadPhotos(){
        // get photos urls
        API.sharedAPI.getStudentLocations(lat: location.lat, lon: location.lon) { (urls, error) in
            if urls != nil{
                API.sharedAPI.downloadPhotos(urls: urls!) {(images, error) in
                    if images?.count != 0 {
                        self.storePhotos(images: images!)
                    } else{
                        print("no images returned")
                    }
                }
            } else{
                print("no photos urls found")
            }
        }
        
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
