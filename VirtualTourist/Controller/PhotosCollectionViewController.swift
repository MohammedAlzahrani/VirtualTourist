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

class PhotosCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet var photosCollectionView: UICollectionView!
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var pin:Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFetchResultsController()
//        if fetchedResultsController.sections?[0].numberOfObjects == 0 {
//            downloadPhotos()
//        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(newPhotosCollection))
    }
    
    func setUpFetchResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            fatalError("fetch request faild: \(error.localizedDescription)")
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        fetchedResultsController = nil
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setUpFetchResultsController()
        if fetchedResultsController.sections?[0].numberOfObjects == 0 {
            downloadPhotos()
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotosCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        // Configure the cell
        if let photoData = photo.photo{
           cell.photoImageView.image = UIImage(data: photoData)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        deletePhotos(photos: [photoToDelete])
        
    }
    

    func storePhotos(images:[UIImage]) {
        for image in images{
            let photo = Photo(context: dataController.viewContext)
            photo.photo = image.pngData()
            photo.creationDate = Date()
            photo.pin = pin
            do{
                try dataController.viewContext.save()
                print("saved")
            }catch {
                print(error)
            }
        }
    }
    func deletePhotos(photos:[Photo]) {
        for photo in photos{
            dataController.viewContext.delete(photo)
            do{
                try dataController.viewContext.save()
            }catch{
                print(error)
            }
        }
    }
    func downloadPhotos(){
        // get photos urls
        API.sharedAPI.getPhotosURLs(lat: pin.lat, lon: pin.lon) { (urls, error) in
            guard (error == nil) else{
                print("no photos urls found")
                return
            }
            if urls != nil{
                API.sharedAPI.downloadPhotos(urls: urls!) {(images, error) in
                    guard (error == nil) else{
                        print("no images returned")
                        return
                    }
                    if images?.count != 0 {
                        self.storePhotos(images: images!)
                        if self.fetchedResultsController.sections?[0].numberOfObjects == urls!.count{
                            DispatchQueue.main.async{self.configureUI(enabled: true)}}
                    }
                }
            }
        }

    }
    @objc func newPhotosCollection(){
        self.configureUI(enabled: false)
        deletePhotos(photos: fetchedResultsController.fetchedObjects!)
        downloadPhotos()
    }
    
    func configureUI(enabled:Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = enabled
    }
 
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            photosCollectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            photosCollectionView.deleteItems(at: [indexPath!])
            break
        case .move:
            break
        case .update:
            break
        }
    }
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        //photosCollectionView.reloadData()
//        //photosCollectionView.beginUpdates()
//        photosCollectionView.performBatchUpdates(nil, completion: nil)
//    }
    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        //photosCollectionView.endUpdates()
//        photosCollectionView.reloadData()
//    }
    
    
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
