//
//  ImageDisplayViewController.swift
//  ImageGallery
//
//  Created by Anna Garcia on 10/1/18.
//  Copyright © 2018 Juice Crawl. All rights reserved.
//

import UIKit

class ImageDisplayViewController: UIViewController, UIScrollViewDelegate {
    
    var imageView = UIImageView()
    var imageUrl: URL?
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 1/25
            scrollView.maximumZoomScale = 1
            scrollView.addSubview(imageView)
            scrollView.delegate = self
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchImage()
    }
    
    private func fetchImage() {
        if let url = imageUrl {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in // weak self, not because of memory cycle, but asynchronous nature.
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents, url == self?.imageUrl { // async fetching still the same url?
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
}
