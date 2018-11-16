//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Anna Garcia on 9/26/18.
//  Copyright © 2018 Juice Crawl. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    enum LoadingState {
        case isLoading
        case loaded(UIImage)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var loadingState: LoadingState = .isLoading {
        didSet {
            switch loadingState {
            case .isLoading:
                imageView.image = nil
                activityIndicator.startAnimating()
            case let .loaded(img):
                imageView.image = img
                activityIndicator.stopAnimating()
            }
        }
    }
}
