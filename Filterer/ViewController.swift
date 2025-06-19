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
    
    var intensityValue: Int
    
    var currentFilter: Filter?
    
    let imageFilters = [0:RedFilter(withIntensity: 255), 1:GreenFilter(withIntensity: 255), 2:BlueFilter(withIntensity: 255), 3:GrayscaleFilter()]
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    @IBOutlet weak var secondaryStackView: UIStackView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet var sliderMenu: UIView!
    
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    
    
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var intensityValueLabel: UILabel!
    
    
    init() {
        self.intensityValue = 128
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.intensityValue = 128
        super.init(coder: aDecoder)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        sliderMenu.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        sliderMenu.translatesAutoresizingMaskIntoConstraints = false
        
        
        intensityValueLabel.text = String(Int(self.intensitySlider.value))
        
        self.currentFilter = self.imageFilters[0]
 
        originalImage = imageView.image
        compareButton.isEnabled = false
        informationView.layer.cornerRadius = 8.0
        informationView.clipsToBounds = true
        informationView.isHidden = false
        filterPlaceholders()
    }
    
    
    @IBAction func onPressImageView(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            self.informationView.isHidden = false
            UIView.animate(withDuration: 0.4) {
                self.overlayImageView.alpha = 0
            }
            break
        case .ended:
            self.informationView.isHidden = true
            UIView.animate(withDuration: 0.4) {
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
        present(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .photoLibrary
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            imageView.image = image
            originalImage = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onPressEdit(sender: UIButton) {
        secondaryMenu.removeFromSuperview();
        filterButton.isSelected = false
        if (sender.isSelected) {
            hideSecondaryMenu(withView: self.sliderMenu)
            sender.isSelected = false
            
        } else {
            showSecondaryMenu(withView: self.sliderMenu)
            sender.isSelected = true
        }
    }

    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        sliderMenu.removeFromSuperview();
        editButton.isSelected = false
        
        if (sender.isSelected) {
            hideSecondaryMenu(withView: self.secondaryMenu)
            sender.isSelected = false
            imageView.image = originalImage
            informationView.isHidden = false
            UIView.animate(withDuration: 0.4){
                self.overlayImageView.alpha = 0
            }
            
        } else {
            showSecondaryMenu(withView: self.secondaryMenu)
            sender.isSelected = true
            
        }
    }
    
    
    func showSecondaryMenu(withView theView: UIView) {
        view.addSubview(theView)
        
        let bottomConstraint = theView.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = theView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = theView.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let height: CGFloat = theView.tag == 1 ? 72 : 44
        
        let heightConstraint = theView.heightAnchor.constraint(equalToConstant: height)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        theView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            theView.alpha = 1.0
        }
    }

    func hideSecondaryMenu(withView theView:UIView) {
        UIView.animate(withDuration: 0.4, animations: {
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
            UIView.animate(withDuration: 0.4) {
                self.overlayImageView.alpha = 1
            }
            
        } else {
            UIView.animate(withDuration: 0.4) {
                self.overlayImageView.alpha = 0
            }
        }
        informationView.isHidden = !isFiltered;
        
        sender.isSelected = isFiltered
    }
    
    
    //SLIDER ACTIONS
    
    
    @IBAction func onSliderValueChanged(sender: AnyObject) {
        self.intensityValueLabel.text = String(Int(self.intensitySlider.value))
        self.intensityValue = Int(self.intensitySlider.value)
    }
    
    
    @IBAction func onSliderTouchUpInside(sender: AnyObject) {
        self.currentFilter?.intensity = Int(self.intensitySlider.value)
        applyAFilter(aFilter: self.currentFilter!)
    }
    
    // FILTER ACTIONS
    
    
    
    
    @IBAction func onRed(sender: UIButton) {
        let redFilter = RedFilter(withIntensity: self.intensityValue)
        applyFilter(aFilter: redFilter, withSender: sender)
    }
    
    @IBAction func onGreen(sender: UIButton) {
        let greenFilter = GreenFilter(withIntensity: self.intensityValue)
        applyFilter(aFilter: greenFilter, withSender: sender)
    }
    
    @IBAction func onBlue(sender: UIButton) {
        let blueFilter = BlueFilter(withIntensity: self.intensityValue)
        applyFilter(aFilter: blueFilter, withSender: sender)
    }
    
    @IBAction func onAlpha(sender: UIButton) {
        let alphaFilter = AlphaFilter()
        applyFilter(aFilter: alphaFilter, withSender: sender)
    }
    
    @IBAction func onGrayscale(sender: UIButton) {
        let grayscaleFilter = GrayscaleFilter()
        applyFilter(aFilter: grayscaleFilter, withSender: sender)
    }
    
    func applyFilter(aFilter: Filter, withSender sender: UIButton) {
        informationView.isHidden = !sender.isSelected
        
        self.currentFilter = aFilter
        
//        sender.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
//        sender.layer.borderColor = UIColor.blueColor().CGColor
        
        if (sender.isSelected) {
            imageView.image = originalImage
            compareButton.isEnabled = false;
            sender.isSelected = false
            UIView.animate(withDuration: 0.4) {
                self.overlayImageView.alpha = 0
            }
            
        } else {
            
            for view in secondaryStackView.subviews {
                if let btn = view as? UIButton {
                    btn.isSelected = (btn === sender)
                }
            }
            
            self.overlayImageView.alpha = 0.5
            
            applyAFilter(aFilter: aFilter)
            
            compareButton.isEnabled = (filteredImage != nil)
            
        }
        compareButton.isSelected = false
    }
    
    
    func filterPlaceholders() {
        
        for view in secondaryStackView.subviews {
            if let btn = view as? UIButton {
                let btnTag = btn.tag
                let btnImage = btn.currentBackgroundImage
                let imageProcessor = ImageProcessor(withUIImage: btnImage!)
                
                imageProcessor.applySingleFilter(aFilter: self.imageFilters[btnTag]!)
                
                btn.setBackgroundImage(imageProcessor.rgbaImage!.toUIImage(), for: .normal)
            }
        }
        
    }
    
    
    func applyAFilter(aFilter: Filter) {
        
        let imageProcessor = ImageProcessor(withUIImage: originalImage!)
        
        imageProcessor.applySingleFilter(aFilter: aFilter)
        
        filteredImage = imageProcessor.rgbaImage!.toUIImage()
        
        overlayImageView.image = filteredImage
        UIView.animate(withDuration: 0.4) {
            self.overlayImageView.alpha = 1
        }
    }

}

