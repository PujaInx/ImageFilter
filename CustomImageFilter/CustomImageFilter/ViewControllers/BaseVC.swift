//
//  BaseVC.swift
//  CustomImageFilter
//
//  Created by Intelivex Labs on 27/03/18.
//  Copyright © 2018 Intelivex Labs. All rights reserved.
//

import UIKit
extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }
        
        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
extension UIViewController {
    
    func showAlert(title : String, message : String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            
        }))
        self.present(alertVC, animated: true, completion: {
        })
    }
    func showActionSheet(title : String, message : String, showTitle  : Bool,actionTitles : [String], actionHander : @escaping ((UIAlertAction, Int) -> Swift.Void), showCancel : Bool = true) {
        var alertVC:UIAlertController = UIAlertController()
        if(showTitle)
        {
            alertVC = UIAlertController(title: title ,message: message, preferredStyle: .actionSheet)
        }
        else
        {
            alertVC = UIAlertController(title: nil ,message: nil, preferredStyle: .actionSheet)
        }
        for (index, actionTitle) in actionTitles.enumerated()
        {
            alertVC.addAction(UIAlertAction.init(title: actionTitle, style: .default, handler: { (action) in
                actionHander(action, index)
            }))
        }
        if showCancel {
            alertVC.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
        }
        self.present(alertVC, animated: true, completion: {
            
        })
    }
}

class BaseVC: UIViewController {
    
    let btnSelectImage = UIButton()
    let imageView = UIImageView()
    let btnAddCopyright = UIButton()
    let txtCopyRight = UITextField()
    var point = CGPoint()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }

    override func loadView() {
        super.loadView()
        self.uiSetUp()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func uiSetUp() {
        
         let btnSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(btnSaveClicked(sender:)))
        self.navigationItem.rightBarButtonItem = btnSave
        
        
        func addConstraint(To stackView:() -> UIStackView)  {
            let stack = stackView()
            stack.translatesAutoresizingMaskIntoConstraints = false
            let top = stack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10)
            let bottom = stack.bottomAnchor.constraint(equalTo:self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
            let left = stack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
            let right = stack.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant:-10)
            NSLayoutConstraint.activate([top,bottom ,right, left])
        }
        
        func setUpSubViewsOfStackView() -> UIStackView {
            
            self.btnSelectImage.translatesAutoresizingMaskIntoConstraints = false
            self.btnSelectImage.setTitle("Select Image", for: .normal)
            self.btnSelectImage.setTitleColor(.black, for: .normal)
            self.btnSelectImage.addTarget(self, action: #selector(btnSelectImageClicked(sender:)), for: .touchUpInside)
            self.btnSelectImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
    
            self.imageView.image = #imageLiteral(resourceName: "default-image_450")
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.translatesAutoresizingMaskIntoConstraints = false
            
            self.btnAddCopyright.translatesAutoresizingMaskIntoConstraints = false
            self.btnAddCopyright.setTitle("Add Copyright Text", for: .normal)
            self.btnAddCopyright.setTitleColor(.black, for: .normal)
            self.btnAddCopyright.addTarget(self, action: #selector(btnAddCopyRightClicked(Sender:)), for: .touchUpInside)
            self.btnAddCopyright.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
            let stackView = UIStackView(arrangedSubviews: [self.btnSelectImage,self.imageView,self.btnAddCopyright])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(stackView)
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.alignment = .fill
            stackView.spacing = 8
            return stackView
        }
        addConstraint(To: setUpSubViewsOfStackView)
    }
    
    @objc func btnSaveClicked(sender:AnyObject) {
        
//        self.imageView.image = #imageLiteral(resourceName: "default-image_450")
        self.imageView.image = self.textToImage(drawText: self.txtCopyRight.text!, inImage: self.imageView.image!, atPoint:self.point)
        UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil)
        
    }
    
    @objc func btnSelectImageClicked(sender: AnyObject) {
        
        self.showActionSheet(title:"", message:"",showTitle:false,actionTitles:["Photo Gallery","Capture a new picture"], actionHander:{ (action, i) in
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                var isSourceTypeAvailable = true
            
                if i == 0 {
                    picker.sourceType = .photoLibrary
                }
                else {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                         picker.sourceType = .camera
                    }
                    else {
                        isSourceTypeAvailable  = false
                        self.showAlert(title: "Sorry cant take picture", message: "Device dosen't support camera")
                    }
                }
            
            if isSourceTypeAvailable {
                picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                self.present(picker, animated:true, completion: {
                })
            }
            
        })
    }
    
   @objc func btnAddCopyRightClicked(Sender:AnyObject) {
    
        self.imageView.addSubview(self.txtCopyRight)
        self.imageView.isUserInteractionEnabled = true

        self.txtCopyRight.translatesAutoresizingMaskIntoConstraints = false
        self.txtCopyRight.text = "Your Copyright Text here"
        self.txtCopyRight.textColor = .white
        self.txtCopyRight.font = UIFont.boldSystemFont(ofSize: 20)
        self.txtCopyRight.centerXAnchor.constraint(equalTo:self.imageView.centerXAnchor).isActive = true
        self.txtCopyRight.centerYAnchor.constraint(equalTo:self.imageView.centerYAnchor).isActive = true
        self.txtCopyRight.isUserInteractionEnabled = true
        self.txtCopyRight.backgroundColor = .cyan
    
//        self.txtCopyRight.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: 10).isActive = true
//        self.txtCopyRight.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: -10).isActive = true
//        self.txtCopyRight.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor, constant: 10).isActive = true
//        self.txtCopyRight.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: -10).isActive = true
    
    let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gestureRecognizer:)))
    self.txtCopyRight.addGestureRecognizer(recognizer)
    recognizer.setTranslation(CGPoint(x: 0,y :0), in: self.imageView)
    
    
    }
    
    @objc func handleGesture(gestureRecognizer:UIPanGestureRecognizer) {
        self.point = gestureRecognizer.location(in: self.imageView)
        let boundRect = self.imageView.contentClippingRect
        
        if (boundRect.contains(point)) {
            self.txtCopyRight.frame.origin.x = point.x
            self.txtCopyRight.frame.origin.y = point.y
            self.txtCopyRight.center = point
            print(point)
            print("boundRect \(boundRect)")
            
        }
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        
        let textColor = UIColor.red
        let textFont = UIFont.boldSystemFont(ofSize: 20)
        
//        let scale = UIScreen.main.scale
        
        UIGraphicsBeginImageContext(image.size)
//        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as [NSAttributedStringKey : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

extension BaseVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismiss(animated: true) {
            self.imageView.image = img
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

