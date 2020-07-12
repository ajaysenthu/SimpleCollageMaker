//
//  CollageMakerViewController.swift
//  SimpleCollageMaker
//
//  Created by mac on 11/07/20.
//  Copyright © 2020 Aj. All rights reserved.
//

import UIKit

class CollageMakerViewController: UIViewController, MultiplePhotoSelectionDelegate {
        
    @IBOutlet weak var canvasView: UIView!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var increaseWidthButton: UIButton!
    
    @IBOutlet weak var decreaseWidthButton: UIButton!
    
    @IBOutlet weak var increaseHeightButton: UIButton!
    
    @IBOutlet weak var decreaseHeightButton: UIButton!
    
    @IBOutlet weak var rotateRightButton: UIButton!
    
    @IBOutlet weak var rotateLeftButton: UIButton!
    
    var photoViews = [UIImageView]()
        
    var selectedPhotoView: (photoView: UIImageView, index: Int, isHighlighted: Bool)? = nil
                        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                        
        self.navigationItem.title = "Make your Collage"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(openPhotos))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export", style: .done, target: self, action: #selector(exportCollage))
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let dropInteraction = UIDropInteraction(delegate: self)
        
        canvasView.addInteraction(dropInteraction)
    }
    
    @objc func openPhotos() {
            
        var photosCollectionViewController = self.storyboard!.instantiateViewController(withIdentifier: "PhotosCollectionViewController") as! PhotosCollectionViewController
        
        photosCollectionViewController = PhotosCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        photosCollectionViewController.delegate = self
        
        let navController = UINavigationController(rootViewController: photosCollectionViewController)
        
        self.present(navController, animated:true, completion: nil)
    }
    
    @objc func exportCollage() {
        
        UIGraphicsBeginImageContext(canvasView.frame.size)
        
        canvasView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        if let image = image {
            
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            activityController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
                        
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    func selectedImages(images: [UIImage]?) {
        
        guard let images = images, images.count > 0 else {
            
            return
        }
        
        hostPhotos(withImages: images)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func hostPhotos(withImages images: [UIImage]) {
        
        for image in images {
            
            let photoView = UIImageView()
            
            if photoViews.count <= 0 {
            
                photoView.frame = CGRect(x: (canvasView.frame.width / 3 + 5), y: (canvasView.frame.height / 3 + 5), width: image.size.width, height: image.size.height)
                
            } else {
                
                photoView.frame.size = CGSize(width: image.size.width, height: image.size.height)
                
                if ((photoViews.last?.frame.origin.x)! + 10) < canvasView.frame.width {
                    
                  photoView.frame.origin.x = (photoViews.last?.frame.origin.x)! + 10
                }
                
                if ((photoViews.last?.frame.origin.x)! - 10) > canvasView.frame.origin.x {
                    
                  photoView.frame.origin.x = (photoViews.last?.frame.origin.x)! - 10
                }
                
                if ((photoViews.last?.frame.origin.y)! + 10) < canvasView.frame.height {
                    
                  photoView.frame.origin.y = (photoViews.last?.frame.origin.y)! + 10
                }
                
                if ((photoViews.last?.frame.origin.y)! - 10) > canvasView.frame.origin.y {
                    
                  photoView.frame.origin.y = (photoViews.last?.frame.origin.y)! - 10
                }
            }
            
            photoView.image = image
            
            let dragInteraction = UIDragInteraction(delegate: self)
            
            dragInteraction.isEnabled = true
                    
            photoView.addInteraction(dragInteraction)
                        
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(photoViewTapped(tapGestureRecognizer:)))
            
            photoView.isUserInteractionEnabled = true
            
            photoView.addGestureRecognizer(tapGestureRecognizer)
            
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateRecognized(_:)))
            
            photoView.addGestureRecognizer(rotationGestureRecognizer)
            
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized(_:)))
            
            photoView.addGestureRecognizer(pinchGestureRecognizer)
            
            photoViews.append(photoView)
            
            canvasView.addSubview(photoView)
        }
    }
    
    @objc func photoViewTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        let tappedPhotoView = tapGestureRecognizer.view as! UIImageView
        
        if tappedPhotoView.layer.borderWidth == 2 {
            
            tappedPhotoView.layer.borderWidth = 0
            
            tappedPhotoView.layer.borderColor = UIColor.clear.cgColor
            
            shouldActivateHighlightComponents(yes: false)
            
            selectedPhotoView = nil
        
        } else {
            
            getSelectedPhotoView(inView: tapGestureRecognizer.view!, session: nil)

            tappedPhotoView.layer.borderWidth = 2
        
            tappedPhotoView.layer.borderColor = UIColor.orange.cgColor
            
            shouldActivateHighlightComponents(yes: true)
        }
    }
    
    @objc func rotateRecognized(_ gestureRecognizer : UIRotationGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else { return }
               
          if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
             gestureRecognizer.view?.transform = gestureRecognizer.view!.transform.rotated(by: gestureRecognizer.rotation)
            
             gestureRecognizer.rotation = 0
          }
    }
    
    @objc func pinchRecognized(_ gestureRecognizer : UIPinchGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
           
            gestureRecognizer.view?.transform = gestureRecognizer.view?.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale) as! CGAffineTransform
            
           gestureRecognizer.scale = 1.0
        }
    }
    
    @IBAction func removeButtonAction(_ sender: UIButton) {
        
        guard let index = self.selectedPhotoView?.index, self.selectedPhotoView?.isHighlighted ?? false else {
            
          return
        }
        
        photoViews.remove(at: index)
        
        for (subIndex, subView) in canvasView.subviews.enumerated() {
            
            if subIndex == index {
                
                if let view = subView as? UIImageView {
                
                  view.removeFromSuperview()
                }
            }
        }
                
        selectedPhotoView = nil
        
        shouldActivateHighlightComponents(yes: false)
        
        if photoViews.count <= 0 {
            
           self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @IBAction func increaseWidth(_ sender: UIButton) {
        
        if selectedPhotoView?.isHighlighted ?? false {
            
            if !(selectedPhotoView?.photoView.transform.isIdentity ?? false) {
                                
                let transform = selectedPhotoView?.photoView.transform
                
                selectedPhotoView?.photoView.transform = CGAffineTransform.identity
                                
                selectedPhotoView?.photoView.frame.size.width = ((selectedPhotoView?.photoView.frame.size.width)!) + 10
                
                selectedPhotoView?.photoView.transform = transform as! CGAffineTransform
            
            } else {

                selectedPhotoView?.photoView.frame.size.width = (selectedPhotoView?.photoView.frame.size.width)! + 10
            }
        }
    }
    
    @IBAction func decreaseWidth(_ sender: UIButton) {
        
        if selectedPhotoView?.isHighlighted ?? false {
            
            if !(selectedPhotoView?.photoView.transform.isIdentity ?? false) {
                                
                let transform = selectedPhotoView?.photoView.transform
                
                selectedPhotoView?.photoView.transform = CGAffineTransform.identity
                                
                selectedPhotoView?.photoView.frame.size.width = ((selectedPhotoView?.photoView.frame.size.width)!) - 10
                
                selectedPhotoView?.photoView.transform = transform as! CGAffineTransform
            
            } else {

               selectedPhotoView?.photoView.frame.size.width = (selectedPhotoView?.photoView.frame.size.width)! - 10
            }
        }
    }
    
    @IBAction func increaseHeight(_ sender: UIButton) {
        
        if selectedPhotoView?.isHighlighted ?? false {
            
            if !(selectedPhotoView?.photoView.transform.isIdentity ?? false) {
                                
                let transform = selectedPhotoView?.photoView.transform
                
                selectedPhotoView?.photoView.transform = CGAffineTransform.identity
                                
            selectedPhotoView?.photoView.frame.size.height = (selectedPhotoView?.photoView.frame.size.height)! + 10
                
                selectedPhotoView?.photoView.transform = transform as! CGAffineTransform
            
            } else {
                
                selectedPhotoView?.photoView.frame.size.height = (selectedPhotoView?.photoView.frame.size.height)! + 10
            }
        }
    }
    
    @IBAction func decreaseHeight(_ sender: UIButton) {
        
        if selectedPhotoView?.isHighlighted ?? false {
            
            if !(selectedPhotoView?.photoView.transform.isIdentity ?? false) {
                                
                let transform = selectedPhotoView?.photoView.transform
                
                selectedPhotoView?.photoView.transform = CGAffineTransform.identity
                                
            selectedPhotoView?.photoView.frame.size.height = (selectedPhotoView?.photoView.frame.size.height)! - 10
                
                selectedPhotoView?.photoView.transform = transform as! CGAffineTransform
            
            } else {

              selectedPhotoView?.photoView.frame.size.height = (selectedPhotoView?.photoView.frame.size.height)! - 10
            }
        }
    }
    
    @IBAction func rotateRightAction(_ sender: UIButton) {
        
        if selectedPhotoView?.isHighlighted ?? false, let index = selectedPhotoView?.index {
        
          selectedPhotoView?.photoView.transform = selectedPhotoView?.photoView.transform.rotated(by: CGFloat(Double.pi / 4)) as! CGAffineTransform
        }
    }
    
    @IBAction func rotateLeftAction(_ sender: UIButton) {
        
        if selectedPhotoView?.isHighlighted ?? false, let index = selectedPhotoView?.index {
        
          selectedPhotoView?.photoView.transform = selectedPhotoView?.photoView.transform.rotated(by: -CGFloat(Double.pi / 4)) as! CGAffineTransform
        }
    }
    
    func getSelectedPhotoView(inView view: UIView, session: UIDragSession? = nil) {
        
        if self.selectedPhotoView?.photoView.frame != view.frame || session != nil {
            
            self.selectedPhotoView?.photoView.layer.borderWidth = 0
            
            self.selectedPhotoView?.photoView.layer.borderColor = UIColor.clear.cgColor
            
            shouldActivateHighlightComponents(yes: false)
        }
        
        self.selectedPhotoView = (UIImageView(), -1, false)
        
        for (index, photoView) in photoViews.enumerated() {
            
            if session != nil {
                
            if photoView.frame.contains(session!.location(in: self.canvasView!)) && photoView.frame == view.frame {
                
                self.selectedPhotoView?.photoView = photoView
                            
                self.selectedPhotoView?.index = index
                
                self.selectedPhotoView?.isHighlighted = false
            }
                
            } else if photoView.frame == view.frame {
                
                self.selectedPhotoView?.photoView = photoView
                            
                self.selectedPhotoView?.index = index
                
                self.selectedPhotoView?.isHighlighted = true
            }
        }
    }
    
    func shouldActivateHighlightComponents(yes: Bool) {
                    
        removeButton.isUserInteractionEnabled = yes
            
        removeButton.alpha = yes ? 1 : 0.25
            
        increaseWidthButton.isUserInteractionEnabled = yes
            
        increaseWidthButton.alpha = yes ? 1 : 0.25
            
        decreaseWidthButton.isUserInteractionEnabled = yes
        
        decreaseWidthButton.alpha = yes ? 1 : 0.25
            
        increaseHeightButton.isUserInteractionEnabled = yes
            
        increaseHeightButton.alpha = yes ? 1 : 0.25
            
        decreaseHeightButton.isUserInteractionEnabled = yes
            
        decreaseHeightButton.alpha = yes ? 1 : 0.25
            
        rotateRightButton.isUserInteractionEnabled = yes
            
        rotateRightButton.alpha = yes ? 1 : 0.25
            
        rotateLeftButton.isUserInteractionEnabled = yes
            
        rotateLeftButton.alpha = yes ? 1 : 0.25
    }
}

extension CollageMakerViewController: UIDropInteractionDelegate, UIDragInteractionDelegate {
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
                
        getSelectedPhotoView(inView: interaction.view!, session: session)
                
        guard let image = self.selectedPhotoView?.photoView.image else { return [] }
                            
        let provider = NSItemProvider(object: image)
                    
        let item = UIDragItem(itemProvider: provider)
                                    
        item.localObject = image
                    
        return [item]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, sessionDidMove session: UIDragSession) {
        
      //  interaction.view?.transform = self.selectedPhotoView?.photoView.transform as! CGAffineTransform
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        // Ensure the drop session has an object of the appropriate type
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        // Propose to the system to copy the item from the source app
        return UIDropProposal(operation: .move)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
                
        session.loadObjects(ofClass: UIImage.self) { [weak self] imageItems in
            
            DispatchQueue.main.async {
                             
                let location = session.location(in: interaction.view!)
                
                guard let selectedIndex = self?.selectedPhotoView?.index else {
                    
                    return
                }
                
                let transform = self?.selectedPhotoView?.photoView.transform
                
                self?.selectedPhotoView?.photoView.transform = CGAffineTransform.identity
                    
                self?.selectedPhotoView?.photoView.frame.origin = CGPoint(x: 0, y: 0)
                
                self?.selectedPhotoView?.photoView.center = CGPoint(x: location.x, y: location.y)
                
                self?.photoViews.remove(at: selectedIndex)
                                
                self?.photoViews.insert((self?.selectedPhotoView?.photoView)!, at: selectedIndex)
                
                self?.selectedPhotoView?.photoView.transform = transform!
            }
        }
    }
}
