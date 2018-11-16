//
//  DocumentBrowserViewController.swift
//  ImageGalleryPersist
//
//  Created by Anna Garcia on 11/2/18.
//  Copyright © 2018 Juice Crawl. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        allowsPickingMultipleItems = false
        allowsDocumentCreation = false
        template = try? FileManager.default.url(
            for: .applicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
            ).appendingPathComponent("Untitled.imagegallery")
        
        if template != nil {
            allowsDocumentCreation = FileManager.default.createFile(
                atPath: template!.path,
                contents: Data()
            )
        }
        print("allowsDocumentCreation", allowsDocumentCreation)
        
        // Update the style of the UIDocumentBrowserViewController
        // browserUserInterfaceStyle = .dark
        // view.tintColor = .white
        
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private var template: URL?
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        importHandler(template, .copy)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let navController = storyBoard.instantiateViewController(withIdentifier: "ImageNavigationController") as? UINavigationController, let galleryVC = navController.visibleViewController as? ImageGalleryCollectionViewController {
            galleryVC.document = ImageGalleryDocument(fileURL: documentURL)
            present(navController, animated: true)
        }
    }
}

