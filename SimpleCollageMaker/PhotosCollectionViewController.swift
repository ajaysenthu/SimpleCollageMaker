//
//  PhotosCollectionViewController.swift
//  SimpleCollageMaker
//
//  Created by mac on 11/07/20.
//  Copyright © 2020 Aj. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "PhotosCellIdentifier"

let itemSize = UIScreen.main.bounds.width/4

protocol MultiplePhotoSelectionDelegate: class {
    
    func selectedImages(images: [UIImage]?)
}

class PhotosCollectionViewController: UICollectionViewController {
    
    weak var delegate: MultiplePhotoSelectionDelegate?
    
    let fetchPhotoService = FetchPhotoService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        
        self.collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
                
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)

        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3

        collectionView.collectionViewLayout = layout
        
        collectionView.allowsMultipleSelection = true
        
        self.collectionView.backgroundColor = .white
                
        self.navigationItem.title = "Select Photos"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissThis))
        
        // Do any additional setup after loading the view.
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
         
            self.fetchPhotoService.loadAllPhotos { (success) in
                
                if success ?? false {
                    
                    DispatchQueue.main.async {
                        
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func dismissThis() {
        
        self.dismiss(animated: true) {
            
            self.delegate?.selectedImages(images: self.fetchPhotoService.getSelectedPhotos(indexPaths: self.collectionView.indexPathsForSelectedItems))
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchPhotoService.allPhotos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
            
        cell.photoImageView?.image = fetchPhotoService.allPhotos[indexPath.row]
                                                                                     
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    // Uncomment this method to specify if the specified item should be selected
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
          
          cell.select()
       }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            
            cell.deSelect()
        }
    }
}
