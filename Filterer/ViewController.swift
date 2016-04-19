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
    
    let imageFilters = [0:RedFilter(withIntensity: 255), 1:GreenFilter(withIntensity: 255), 2:BlueFilter(withIntensity: 255), 3:GrayscaleFilter()]
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    
    @IBOutlet weak var secondaryStackView: UIStackView!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var informationView: UIView!
    
    @IBOutlet var sliderMenu: UIView!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var intensitySlider: UISlider!
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
        informationView.layer.cornerRadius = 8.0
        informationView.clipsToBounds = true
        informationView.hidden = false
        filterPlaceholders()
    }
    
    
    @IBAction func onPressImageView(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .Began:
            self.informationView.hidden = false
            UIView.animateWithDuration(0.4) {
                self.overlayImageView.alpha = 0
            }
            break
        case .Ended:
            self.informationView.hidden = true
            UIView.animateWithDuration(0.4) {
                self.overlayImageView.alpha = 1
            }
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
    
    @IBAction func onPressEdit(sender: UIButton) {
        secondaryMenu.removeFromSuperview();
        if (sender.selected) {
            hideSecondaryMenu(withView: self.sliderMenu)
            sender.selected = false
            
        } else {
            showSecondaryMenu(withView: self.sliderMenu)
            sender.selected = true
        }
    }

    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        sliderMenu.removeFromSuperview();
        if (sender.selected) {
            hideSecondaryMenu(withView: self.secondaryMenu)
            sender.selected = false
            imageView.image = originalImage
            informationView.hidden = false
            UIView.animateWithDuration(0.4){
                self.overlayImageView.alpha = 0
            }
            
        } else {
            showSecondaryMenu(withView: self.secondaryMenu)
            sender.selected = true
        }
    }
    
    func showSecondaryMenu(withView theView: UIView) {
        view.addSubview(theView)
        
        let bottomConstraint = theView.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = theView.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = theView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = theView.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        //view.layoutIfNeeded()
        
        theView.alpha = 0
        UIView.animateWithDuration(0.4) {
            theView.alpha = 1.0
        }
    }

    func hideSecondaryMenu(withView theView:UIView) {
        UIView.animateWithDuration(0.4, animations: {
            theView.alpha = 0
            }) { completed in
                if completed == true {
                    theView.removeFromSuperview()
                }
        }
    }
    
    @IBAction func onCompare(sender: UIButton) {
        
        let isFiltered:Bool = self.overlayImageView.alpha == 1
        
        if (!isFiltered) {
            UIView.animateWithDuration(0.4) {
                self.overlayImageView.alpha = 1
            }
        } else {
            UIView.animateWithDuration(0.4) {
                self.overlayImageView.alpha = 0
            }
            informationView.hidden = false;
        }
        
        sender.selected = isFiltered
        
        
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
        informationView.hidden = !sender.selected
        
        if (sender.selected) {
            imageView.image = originalImage
            compareButton.enabled = false;
            sender.selected = false
            UIView.animateWithDuration(0.4) {
                self.overlayImageView.alpha = 0
            }
            
        } else {
            for view in secondaryStackView.subviews {
                if let btn = view as? UIButton {
                    btn.selected = (btn === sender)
                }
            }
            self.overlayImageView.alpha = 0.5
            
            let imageProcessor = ImageProcessor(withUIImage: originalImage!)
            
            imageProcessor.applySingleFilter(aFilter)
            
            filteredImage = imageProcessor.rgbaImage!.toUIImage()
            
            compareButton.enabled = (filteredImage != nil)
            
            overlayImageView.image = filteredImage
            UIView.animateWithDuration(0.4) {
                self.overlayImageView.alpha = 1
            }
            
        }
        compareButton.selected = false
    }
    
    
    func filterPlaceholders() {
        
        for view in secondaryStackView.subviews {
            if let btn = view as? UIButton {
                let btnTag = btn.tag
                let btnImage = btn.currentBackgroundImage
                let imageProcessor = ImageProcessor(withUIImage: btnImage!)
                
                imageProcessor.applySingleFilter(self.imageFilters[btnTag]!)
                
                btn.setBackgroundImage(imageProcessor.rgbaImage!.toUIImage(), forState: UIControlState.Normal)
                
            }
        }
        
    }

}

