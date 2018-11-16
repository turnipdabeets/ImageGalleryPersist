//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Anna Garcia on 9/26/18.
//  Copyright © 2018 Juice Crawl. All rights reserved.
//

import Foundation

// Model representing a gallery's image.
struct Image:Codable {
    var URL: URL?
    var aspectRatio: Double?
    var data: Data?
    
    init(URL: URL?, aspectRatio:Double?) {
        self.URL = URL
        self.aspectRatio = aspectRatio
    }
}

// Model representing a gallery with images.
struct ImageGallery: Codable {
    //    let identifier = UUID().uuidString
    var title: String
    var images: [Image]
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data){
        if let value = try? JSONDecoder().decode(ImageGallery.self, from: json) {
            title = value.title
            images = value.images
        }else { return nil }
    }
    
    init(title: String = "Untitled", images: [Image] = [Image]()) {
        self.title = title
        self.images = images
    }
}

// Model representing museum
//class Museum {
//    // Assumes currentDocuments are at idx 0 and deletedDocuments are at the last idx
//
//    // singlton approach
//    static let shared = Museum()
//
//    var gallerySections = [
//        (title: "Image Galleries", galleries: [
//            ImageGallery(
//                title: "Untitled",
//                images: [])
//            ]),
//        (title: "Recently Deleted", galleries:[
//            ImageGallery(title: "test", images: [])
//            ])
//    ]
//
//    var deletedSection: Int {
//        return gallerySections.count - 1
//    }
//
//    var currentSection: Int {
//        return 0
//    }
//
//    var galleryNames : [String] {
//        return Array(
//            gallerySections.map{ $0.galleries }.compactMap({ $0.isEmpty ? [""] : $0.compactMap{ $0.title } }).joined()
//        )
//    }
//
//    func createNewGallery(with title: String){
//        gallerySections[currentSection].galleries.insert(ImageGallery(title: title, images: []), at: 0)
//    }
//
//    func add(gallery: ImageGallery, to section: Int){
//        gallerySections[section].galleries += [gallery]
//    }
//
//    func removeGallery(from section: Int, at indexPath: Int) -> ImageGallery {
//        return gallerySections[section].galleries.remove(at: indexPath)
//    }
//
//    func add(image: Image, at indexPath: Int, for section: Int, galleryNumber row: Int){
//        gallerySections[section].galleries[row].images.insert(image, at: indexPath)
//    }
//
//    func remove(image: Image, at indexPath: Int, for section: Int, galleryNumber row: Int){
//        gallerySections[section].galleries[row].images.remove(at: indexPath)
//    }
//
//    func setGallery(title: String, at indexPath: IndexPath) {
//        return gallerySections[indexPath.section].galleries[indexPath.row].title = title
//    }
//
//
//}

