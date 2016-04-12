//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var originalImage: UIImage?
    var filteredImage: UIImage?
    
    var imageProcessor: ImageProcessor?
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    
    @IBOutlet weak var secondaryStackView: UIStackView!
    @IBOutlet weak var compareButton: UIButton!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        originalImage = imageView.image
        compareButton.enabled = false
    }
    
    
    @IBAction func onPressImageView(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .Began:
            imageView.image = originalImage
            break
        case .Ended:
            imageView.image = filteredImage
            break
        default:
            break
        }
        
    }
    
    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            originalImage = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
            
        } else {
            showSecondaryMenu()
            sender.selected = true
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }

    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }
    
    @IBAction func onCompare(sender: UIButton) {
        imageView.image = originalImage
    }
    
    // FILTER ACTIONS
    
    
    
    @IBAction func onRed(sender: UIButton) {
        let redFilter = RedFilter(withIntensity: 255)
        applyFilter(redFilter, withSender: sender)
    }
    
    @IBAction func onGreen(sender: UIButton) {
        let greenFilter = GreenFilter(withIntensity: 255)
        applyFilter(greenFilter, withSender: sender)
    }
    
    @IBAction func onBlue(sender: UIButton) {
        let blueFilter = BlueFilter(withIntensity: 255)
        applyFilter(blueFilter, withSender: sender)
    }
    
    @IBAction func onAlpha(sender: UIButton) {
        let alphaFilter = AlphaFilter()
        applyFilter(alphaFilter, withSender: sender)
    }
    
    @IBAction func onGrayscale(sender: UIButton) {
        let grayscaleFilter = GrayscaleFilter()
        applyFilter(grayscaleFilter, withSender: sender)
    }
    
    func applyFilter(aFilter: Filter, withSender sender: UIButton) {
        if (sender.selected) {
            imageView.image = originalImage
            compareButton.enabled = false;
            sender.selected = false
        } else {
            for view in secondaryStackView.subviews {
                if let btn = view as? UIButton {
                    btn.selected = (btn === sender)
                }
            }
            
            let imageProcessor = ImageProcessor(withUIImage: originalImage!)
            
            imageProcessor.applySingleFilter(aFilter)
            
            filteredImage = imageProcessor.rgbaImage!.toUIImage()
            
            if (filteredImage != nil) {
                compareButton.enabled = true
            }
            
            imageView.image = filteredImage
            
        }
    }

}

