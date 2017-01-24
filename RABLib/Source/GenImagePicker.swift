//
//  GenImagePicker.swift
//  RAB
//
//  Created by RAB on 11/10/15.
//  Copyright © 2015 Rab LLC. All rights reserved.
//

import Foundation
import UIKit

public protocol GenImagePickerDelegate {
    func didFinishPickingImage(_ image: UIImage)
    func cancelPickingImage()
    func cancelActionSheet()
}

open class GenImagePicker: NSObject {
    
    open var delegate: GenImagePickerDelegate?
    var alert: UIAlertController!
    
    /**
     * Displays the image picker alert
     *
     * iPad Use: 
     * showPopOverOnView: pass the uibutton or uiview, and the popover
     * will display on this item.
     */
    open func show(_ viewController: UIViewController,
                   showPopOverOnView: UIView? = nil) {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        { [unowned self] (action) -> Void in
            self.delegate?.cancelActionSheet()
        }
        
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .default)
        { [unowned self] (action) -> Void in
            self.captureFromCamera(viewController)
        }
        
        let libraryAction = UIAlertAction(title: "Choose from Library", style: .default)
        { [unowned self] (action) -> Void in
            self.selectImageFromGallery(viewController)
        }
        
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        
        if let presenter = alert.popoverPresentationController {
            if let rightButton = viewController.navigationItem.rightBarButtonItem {
                presenter.barButtonItem = rightButton
            } else if let v = showPopOverOnView {
                presenter.sourceView = v
                presenter.sourceRect = v.bounds
            } else {
                presenter.sourceView = viewController.view
                presenter.sourceRect = viewController.view.bounds
            }
        }
        viewController.present(alert, animated: true, completion: nil)
    }
    
    var customizeLook: [String: AnyObject]!
    
    /**
     call this on the object to add color customizations
     
     - parameter translucent:              Translucent Background
     - parameter barTintColor:             Background color
     - parameter tintColor:                Cancel button ~ any UITabBarButton items
     - parameter titleTextAttributesColor: Title color
     */
    open func addCustomizeLook(_ translucent: Bool, barTintColor: UIColor,
        tintColor: UIColor, titleTextAttributesColor: UIColor ) {
        customizeLook = ["translucent": translucent as AnyObject, "barTintColor": barTintColor,
            "tintColor": tintColor, "titleTextAttributesColor": titleTextAttributesColor]
    }
    
    fileprivate func customizeImagePicker(_ imagePicker: UIImagePickerController) {
        if customizeLook != nil {
            imagePicker.navigationBar.isTranslucent = customizeLook["translucent"] as! Bool
            imagePicker.navigationBar.barTintColor = customizeLook["barTintColor"] as? UIColor
            imagePicker.navigationBar.tintColor = customizeLook["tintColor"] as? UIColor
            imagePicker.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName : customizeLook["titleTextAttributesColor"] as! UIColor
            ] // Title color
        }
    }
    
    deinit {
        pln()
    }
    
    func captureFromCamera(_ viewController: UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            pln("Button capture")
            let imag = UIImagePickerController()
            customizeImagePicker(imag)
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.camera
            imag.allowsEditing = false
            viewController.present(imag, animated: true, completion: nil)
        }
    }
    
    func selectImageFromGallery(_ viewController: UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            pln("Button capture")
            let imag = UIImagePickerController()
            customizeImagePicker(imag)
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imag.allowsEditing = false
            viewController.present(imag, animated: true, completion: nil)
        }
    }
}

extension GenImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.delegate?.didFinishPickingImage(image)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.delegate?.cancelPickingImage()
    }
}