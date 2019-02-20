//
//  PhotosCollectionViewController.swift
//  VirtualTourist
//
//  Created by Mohammed ALZAHRANI on 08/02/2019.
//  Copyright © 2019 Mohammed ALZAHRANI. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher
private let reuseIdentifier = "PhotosCollectionViewCell"

class PhotosCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    // MARK:- Outlets
    @IBOutlet var photosCollectionView: UICollectionView!
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var pin:Pin!
    var urls:[URL] = []
    var downloadCounter = 0
    
    // MARK:- View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFetchResultsController()
        // add button on the right side of the navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(newPhotosCollection))
        if fetchedResultsController.sections?[0].numberOfObjects == 0 {
            getPhotosURLs()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        fetchedResultsController = nil
        urls = []
        downloadCounter = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setUpFetchResultsController()
    }
    
    // MARK:- UIcollectionView data source
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if urls.isEmpty{
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }else{
            return urls.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotosCollectionViewCell
        // load photos from DB
        if urls.isEmpty{
            let photo = fetchedResultsController.object(at: indexPath)
            if let photoData = photo.photo{
                cell.photoImageView.image = UIImage(data: photoData)
            }
        }
        // download photos
        else{
            let placeHolderImage = UIImage(named:"placeholder")
            cell.photoImageView.kf.indicatorType = .activity
            cell.photoImageView.kf.setImage(with: urls[indexPath.row], placeholder: placeHolderImage){ result in
                switch result {
                case .success(let value):
                    // store the downloaded photo in DB
                    self.storePhotos(images: [value.image])
                    self.downloadCounter += 1
                    // when all photos finish downloading
                    if self.downloadCounter == self.urls.count{
                        self.urls.removeAll()
                        DispatchQueue.main.async{
                            self.photosCollectionView.reloadData()
                            self.configureUI(enabled: true)
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async{
                        self.showAlert(message: error.localizedDescription)
                    }
                }
            }

        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // delete a photo when tapped
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        deletePhotos(photos: [photoToDelete])
    }
    
    // MARK:- Photos functions
    
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
    // store photos in DB
    func storePhotos(images:[UIImage]) {
        for image in images{
            let photo = Photo(context: dataController.viewContext)
            photo.photo = image.pngData()
            photo.creationDate = Date()
            photo.pin = pin
            do{
                try dataController.viewContext.save()
            }catch {
                print(error)
            }
        }
    }
    // delete photos form DB
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
    // get photos URLs
    func getPhotosURLs(){
        API.sharedAPI.getPhotosURLs(lat: pin.lat, lon: pin.lon) { (urls, error) in
            guard (error == nil) else{
                self.showAlert(message: error!)
                return
            }
            if urls != nil{
                DispatchQueue.main.async{
                    self.urls = urls!
                    self.photosCollectionView.reloadData()
                }
                
            }
        }

    }
    // MARK:- Actions
    // delete existing photos and download new photos
    @objc func newPhotosCollection(){
        self.configureUI(enabled: false)
        deletePhotos(photos: fetchedResultsController.fetchedObjects!)
        getPhotosURLs()
    }
    
    func configureUI(enabled:Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = enabled
    }
    // MARK:-  UI updates
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
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

}
