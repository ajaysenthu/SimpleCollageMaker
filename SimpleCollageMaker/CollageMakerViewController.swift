//
//  CollageMakerViewController.swift
//  SimpleCollageMaker
//
//  Created by mac on 11/07/20.
//  Copyright © 2020 Aj. All rights reserved.
//

import UIKit

class CollageMakerViewController: UIViewController, MultiplePhotoSelectionDelegate {
                
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        
        self.navigationItem.title = "Make your Collage"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(openPhotos))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export", style: .done, target: nil, action: nil)
    }
    
    @objc func openPhotos() {
            
        var photosCollectionViewController = self.storyboard!.instantiateViewController(withIdentifier: "PhotosCollectionViewController") as! PhotosCollectionViewController
        
        photosCollectionViewController = PhotosCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        photosCollectionViewController.delegate = self
        
        let navController = UINavigationController(rootViewController: photosCollectionViewController)
        
        self.present(navController, animated:true, completion: nil)
    }
    
    func selectedImages(images: [UIImage]?) {
        
        guard let images = images else {
            
            return
        }
        
        print(images)
    }
}
