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
    @IBOutlet var photosCollectionView: UICollectionView!
    var dataController: DataController!
    var location:Location!
    var photos:[UIImage] = []
    var dbPhotos:[Photo] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotos()
        if photos.isEmpty{
            downloadPhotos()
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(newPhotosCollection))
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        photos.removeAll()
        dbPhotos.removeAll()
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if  photos.isEmpty{
            return 0
        } else{
            return photos.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotosCollectionViewCell
        // Configure the cell
        cell.photoImageView.image = photos[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhotos(photos: [dbPhotos[indexPath.row]], index: indexPath.row)
//        photos.remove(at: indexPath.row)
        collectionView.reloadData()
    }
    
    func fetchPhotos(){
        let photosDB:[Photo]
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "location == %@", location)
        fetchRequest.predicate = predicate
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            photosDB = result
            print("number of fetched photos: \(photosDB.count)")
            self.dbPhotos.removeAll()
            self.photos.removeAll()
            for photo in photosDB{
                dbPhotos.append(photo)
                photos.append(UIImage(data: photo.photo!)!)
                print("appended")
            }
            self.photosCollectionView.reloadData()
        } else{
            print("fetch error")
        }
    }
    func storePhotos(images:[UIImage]) {
        for image in images{
            let photo = Photo(context: dataController.viewContext)
            photo.photo = image.pngData()
            photo.location = location
            do{
                try dataController.viewContext.save()
                print("saved")
//                dbPhotos.append(photo)
//                photos.append(image)
            }catch {
                print(error)
            }
        }
        fetchPhotos()
//        self.photosCollectionView.reloadData()
    }
    func deletePhotos(photos:[Photo], index:Int?) {
        for photo in photos{
            dataController.viewContext.delete(photo)
            do{
                try dataController.viewContext.save()
                if index != nil{
                    self.photos.remove(at: index!)
                    self.dbPhotos.remove(at: index!)
                } else{
                    self.photos.removeAll()
                    self.dbPhotos.removeAll()
                }
            }catch{
                print(error)
            }
        }
    }
    func downloadPhotos(){
        // get photos urls
        API.sharedAPI.getPhotosURLs(lat: location.lat, lon: location.lon) { (urls, error) in
            DispatchQueue.main.async{self.configureUI(enabled: false)}
            if urls != nil{
                API.sharedAPI.downloadPhotos(urls: urls!) {(images, error) in
                    if images?.count != 0 {
                        self.storePhotos(images: images!)
                        DispatchQueue.main.async{self.configureUI(enabled: true)}
                    } else{
                        print("no images returned")
                    }
                }
            } else{
                print("no photos urls found")
            }
        }
        
    }
    @objc func newPhotosCollection(){
//        self.navigationItem.rightBarButtonItem?.isEnabled = false
        deletePhotos(photos: dbPhotos, index: nil)
        //photos = []
        downloadPhotos()
//        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func configureUI(enabled:Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = enabled
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
