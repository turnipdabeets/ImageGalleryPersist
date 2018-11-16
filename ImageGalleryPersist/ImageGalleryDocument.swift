//
//  ImageGalleryDocument.swift
//  ImageGalleryPersist
//
//  Created by Anna Garcia on 11/2/18.
//  Copyright © 2018 Juice Crawl. All rights reserved.
//

import UIKit

class ImageGalleryDocument: UIDocument {
    
    var gallery: ImageGallery?
    var thumbnail: UIImage?
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return gallery?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        if let json = contents as? Data {
            gallery = ImageGallery(json: json)
        }
    }
}

