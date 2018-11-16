//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Anna Garcia on 9/26/18.
//  Copyright © 2018 Juice Crawl. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCell"

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    var document: ImageGalleryDocument?
    var gallery: ImageGallery?
    
    private var imageWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return (collectionView.frame.size.width / 2) - 5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if document?.documentState == .closed {
            document?.open { [weak self] success in
                if success {
                    self?.title = self?.document?.localizedName
                    if let gallery = self?.document?.gallery {
                        self?.gallery = gallery
                    }else {
                        self?.gallery = ImageGallery(title: self?.document?.localizedName ?? "Not Named")
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GALLERY", gallery ?? "none")
        // enable drag for iPhone
        collectionView?.dragInteractionEnabled = true
        // set delegate
        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
    }
    
    // Cell Resizing on Device Rotation
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery?.images.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Get cell by reuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the imageCell
        if let imageCell = cell as? ImageCollectionViewCell, let data = gallery?.images[indexPath.row].data, let image = UIImage(data: data) {
            imageCell.loadingState = .loaded(image)
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let aspectRatio = gallery?.images[indexPath.row].aspectRatio else {
            return CGSize(width: 10, height: 10)
        }
        // let aspectRatio = image.size.width / image.size.height
        let imageHeight = imageWidth / CGFloat(aspectRatio)
        return CGSize(width: imageWidth, height: imageHeight)
    }
    
    // MARK: UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let _ = collectionView?.cellForItem(at: indexPath) as? ImageCollectionViewCell, let image = gallery?.images[indexPath.row] {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: UIImage(data: image.data!)!))
            // pass Image type for local droping
            dragItem.localObject = image
            return [dragItem]
        }
        return []
    }
    
    // MARK: UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        //TODO, local doesnt have URL but need this for remote
        if (collectionView.hasActiveDrag){
            // local case only
            return session.canLoadObjects(ofClass: UIImage.self)
        }else {
            // remote case need both image for aspect ratio and url
            return session.canLoadObjects(ofClass: UIImage.self) && session.canLoadObjects(ofClass:URL.self)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(
            operation: isSelf ? .move : .copy,
            intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            // Local Drop
            if let sourceIndexPath = item.sourceIndexPath {
                if let image = item.dragItem.localObject as? Image {
                    collectionView.performBatchUpdates({
                        gallery?.images.remove(at: sourceIndexPath.item)
                        gallery?.images.insert(image, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                        document?.updateChangeCount(.done)
                    })
                }
                // External Drop
            } else {
                // get url, aspectratio and data and set as Image
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to:UICollectionViewDropPlaceholder(
                        insertionIndexPath: destinationIndexPath,
                        reuseIdentifier: "DropPlaceholderCell"
                    )
                )
                // start creation of a new Image
                var newImage = Image(URL: nil, aspectRatio: 1)
                // Get UIImage
                _ = item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            newImage.aspectRatio = Double(image.size.width / image.size.height)
                        }
                    }
                }
                // Get URL
                _ = item.dragItem.itemProvider.loadObject(ofClass: URL.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider?.imageURL {
                            newImage.URL = url
                            // Start background thread so image loading does not make app unresponsive
                            DispatchQueue.global(qos: .userInitiated).async {
                                URLSession.init(configuration: .default).dataTask(with: url) { (data, response, error) in
                                    // The download has finished.
                                    if let e = error {
                                        print("P: Error downloading picture: \(e)")
                                        placeholderContext.deletePlaceholder()
                                    } else {
                                        // No errors found.
                                        if let res = response as? HTTPURLResponse {
                                            print("P: Downloaded picture with response code \(res.statusCode)")
                                            if let imageData = data {
                                                // UI needs to be updated on main queue
                                                DispatchQueue.main.async {
                                                    // Done loading
                                                    newImage.data = imageData
                                                placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                                    print("P: DOES IT CRASH HERE?", self.gallery, self.document)
                                                    self.gallery?.images.insert(newImage, at: insertionIndexPath.item)
                                                    self.document?.updateChangeCount(.done)
                                                    })
                                                    print("P: OR HERE?")
                                                }
                                            } else {
                                                print("P: Couldn't get image: Image is nil")
                                            }
                                        } else {
                                            print("P: Couldn't get response code for some reason")
                                        }
                                    }
                                    }.resume()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        if let indexPath = collectionView?.indexPathsForSelectedItems, let vc = segue.destination as? ImageDisplayViewController {
            vc.imageUrl = gallery?.images[indexPath[0].row].URL
        }
        // Pass the selected object to the new view controller.
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
