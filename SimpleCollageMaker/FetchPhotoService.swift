//
//  FetchPhotoService.swift
//  SimpleCollageMaker
//
//  Created by mac on 11/07/20.
//  Copyright © 2020 Aj. All rights reserved.
//

import Foundation
import UIKit
import Photos

typealias ImageCallback = (_ image: UIImage?) -> Void

typealias SuccessCallback = (_ success: Bool?) -> Void

class FetchPhotoService {
    
    var photoAssets : PHFetchResult<PHAsset>? = nil
    
    var allPhotos = [UIImage]()
    
    init() {
        
       requestPhotosFromPhotoLibrary()
    }
    
    func requestPhotosFromPhotoLibrary() {
        
        PHPhotoLibrary.requestAuthorization { (status) in
            
            switch status {
                
            case .authorized:

              let fetchOptions = PHFetchOptions()
              
              self.photoAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                              
            case .denied, .restricted:
              
                print("Access Denied")
              
            case .notDetermined:
              
                print("Not Determined")
              
            @unknown default:
              fatalError()
          }
        }
    }
    
    func loadAllPhotos(_ completion: @escaping SuccessCallback) {
        
        var index = 0
        
        func loadPhoto() {
        
            fetchImage(asset: (self.photoAssets?.object(at: index))!, contentMode: .aspectFit, targetSize: CGSize(width: itemSize, height: itemSize)) { (image) in
                
                if let image = image {
                    
                  self.allPhotos.append(image)
                }
                
                index = index + 1
                
                if index == self.photoAssets?.count {
                    
                  completion(true)
                
                } else {
                    
                   loadPhoto()
                }
            }
            
        }
        
        loadPhoto()
    }
    
    func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize, completion: ImageCallback? = nil) {
       
       let options = PHImageRequestOptions()
       
       options.version = .original
       
       PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
                                         
           completion?(image)
         }
      }
    
    func getSelectedPhotos(indexPaths: [IndexPath]?) -> [UIImage] {
        
        guard  let indexPaths = indexPaths else {
            
          return []
        }
        
        var selectedPhotos = [UIImage]()
        
        for indexpath in indexPaths {
            
            selectedPhotos.append(self.allPhotos[indexpath.row])
        }
        
        return selectedPhotos
    }
}
