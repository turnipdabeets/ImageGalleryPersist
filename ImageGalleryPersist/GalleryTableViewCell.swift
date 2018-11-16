//
//  GalleryTableViewCell.swift
//  ImageGallery
//
//  Created by Anna Garcia on 10/1/18.
//  Copyright © 2018 Juice Crawl. All rights reserved.
//

import UIKit

protocol GallerySelectionTableViewCellDelegate {
    func titleDidChange(_ title: String, in cell: UITableViewCell)
}

class GalleryTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    /// The cell's delegate
    var delegate: GallerySelectionTableViewCellDelegate?
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            // check when textField editing ends
            textField.returnKeyType = .done
            textField.delegate = self
        }
    }
    
    /// The row's title.
    var title: String? {
        set {
            textField?.text = newValue
        }
        get {
            return textField?.text ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Disable editing
        textField.isUserInteractionEnabled = false
        
        // Initialization code with gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(tapGesture)
    }
    
    @objc func doubleTapped(_ sender: UITextField){
        // Enable editing
        textField.isUserInteractionEnabled = true
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // resign keyboard when user hits done button
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // user has resigned responder
        // Disable edit
        textField.isUserInteractionEnabled = false
        
        guard let title = textField.text, title != "" else {
            return
        }
        // Save new title
        delegate?.titleDidChange(title, in: self)
    }
}
