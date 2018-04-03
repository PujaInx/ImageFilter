//
//  BaseVC.swift
//  CustomImageFilter
//
//  Created by Intelivex Labs on 27/03/18.
//  Copyright © 2018 Intelivex Labs. All rights reserved.
//

import UIKit
extension UIImage {
    
//    /// Returns a image that fills in newSize
//    func resizedImage(newSize: CGSize) -> UIImage {
//        // Guard newSize is different
//        guard self.size != newSize else { return self }
//
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
//        self.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
//
//
//
//        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return newImage
//    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    
    
    func scaledImageWithinRect(rectSize: CGSize,text: String,point:CGPoint,imgFrame:CGRect) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        
        
        let textColor = UIColor.red
        let textFont = UIFont.boldSystemFont(ofSize: 20)
        let textFontAttributes = [
                    NSAttributedStringKey.font: textFont,
                    NSAttributedStringKey.foregroundColor: textColor,
                    ] as [NSAttributedStringKey : Any]
        
        
//        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        
//        let rect = CGRect(origin: point, size: CGSize(width: imgFrame.size.width, height: imgFrame.size.height))
        let rect = CGRect.init(x: point.x, y: point.y, width: newSize.width, height: newSize.height)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
//        let resized = resizedImage(newSize: newSize)
        return newImage
    }
    
}
extension UIImageView {
    var contentClippingRect: CGRect {
        
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        }else{
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
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
        self.present(alertVC, animated: true, completion: {})
    }
}

class BaseVC: UIViewController {
    var imageCenterXConstraint:NSLayoutConstraint = NSLayoutConstraint()
    var imageCenterYConstraint:NSLayoutConstraint = NSLayoutConstraint()

    var beginningPoint:CGPoint!
    var beginningCenter:CGPoint!
    var touchLocation:CGPoint!
    
    let btnSelectImage = UIButton()
    let imageView = UIImageView()
    let btnAddCopyright = UIButton()
    var txtCopyRight = UITextField()
    var point = CGPoint()
    var rect = CGRect()
    var enableMoveRestriction:Bool = true
    
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
    
    @objc func setBtnHidden() {
        self.txtCopyRight.isHidden = true
    }
    
    @objc func btnSaveClicked(sender:AnyObject) {
        
        self.imageView.image = self.textToImage(drawText: self.txtCopyRight.text!, inImage: self.imageView.image!, atPoint:self.point, imgFrame: rect)
        UIImageWriteToSavedPhotosAlbum(self.imageView.image!,self,nil, nil)
        self.txtCopyRight.isHidden = true
        self.txtCopyRight.isUserInteractionEnabled = false
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
    
        self.txtCopyRight.isHidden = false;
        self.txtCopyRight.isUserInteractionEnabled = true
        self.imageView.addSubview(self.txtCopyRight)
        self.imageView.isUserInteractionEnabled = true

        self.txtCopyRight.translatesAutoresizingMaskIntoConstraints = false
        self.txtCopyRight.text = "Your Copyright Text here"
        self.txtCopyRight.textColor = .white
        self.txtCopyRight.font = UIFont.boldSystemFont(ofSize: 20)
        self.txtCopyRight.centerXAnchor.constraint(equalTo:self.imageView.centerXAnchor).isActive = true
        self.txtCopyRight.centerYAnchor.constraint(equalTo:self.imageView.centerYAnchor).isActive = true
    
    
    
    self.imageCenterXConstraint = self.txtCopyRight.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor)
    self.imageCenterXConstraint.isActive = true
    self.imageCenterYConstraint = self.txtCopyRight.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor)
    self.imageCenterYConstraint.isActive = true
    
        self.txtCopyRight.isUserInteractionEnabled = true
        self.txtCopyRight.backgroundColor = .cyan
    
    let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(rec:)))
    recognizer.maximumNumberOfTouches = 1
    recognizer.minimumNumberOfTouches = 1
    self.txtCopyRight.addGestureRecognizer(recognizer)
//    recognizer.setTranslation(CGPoint(x: 0,y :0), in: self.imageView)
    }
    
    @objc func handleGesture(rec:UIPanGestureRecognizer) {
        
        
        touchLocation = rec.location(in: self.imageView)
        switch rec.state {
        case .began:
                beginningPoint = touchLocation
                beginningCenter = self.txtCopyRight.center
                self.txtCopyRight.center  = self.estimatedCenter()
            break
        case .changed:
            self.txtCopyRight.center  = self.estimatedCenter()
            break
        case .ended:
            self.txtCopyRight.center  = self.estimatedCenter()
            self.point = self.estimatedCenter()
            break
        default:
            break
        }
        

        
//        self.point = CGPoint.zero
//        self.rect = CGRect.zero
//        var firstX:CGFloat = 0.0
//        var firstY:CGFloat = 0.0
//        self.point = rec.location(in: self.imageView)
//        let boundRect = self.imageView.contentClippingRect
//        if (boundRect.contains(point)) {
//
//            var translatedPoint = rec.translation(in: self.imageView)
//            if rec.state == .began {
//                firstX  = (rec.view?.center.x)!
//                firstY = (rec.view?.center.y)!
//            }
//            translatedPoint = CGPoint(x: firstX+translatedPoint.x, y: firstY+translatedPoint.y)
//
//            self.txtCopyRight.center = translatedPoint
//            self.point = translatedPoint
//
//        }
        
//        CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
//        if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
//            firstX = [[sender view] center].x;
//            firstY = [[sender view] center].y;
//        }
//        translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
//        [[sender view] setCenter:translatedPoint];
        
//        self.point = rec.location(in: self.imageView)
//        let boundRect = self.imageView.contentClippingRect
//        if (boundRect.contains(point)) {
////
////            print("point:    \(point)")
////            print("txtfield:    \(self.txtCopyRight.frame)")
//
//
//            if point.x >= 0
//            {
//                if let frame = self.txtCopyRight.superview?.convert(self.txtCopyRight.frame, to: nil) {
//
//                    var finalPoint = CGPoint(x:(point.x - (frame.size.width/2))  , y: (point.y - (frame.size.height/2)))
//
//                    if finalPoint.x >= 0 {
//                        self.txtCopyRight.frame.origin.x = finalPoint.x
//                    }
//                    else  {
//                        self.txtCopyRight.frame.origin.x = 0
//                        finalPoint.x = 0
//                    }
//
//
//                    if finalPoint.y >= 0 {
//                        self.txtCopyRight.frame.origin.y = finalPoint.y
//                    }
//                    else  {
//                        self.txtCopyRight.frame.origin.y = 0
//                        finalPoint.y = 0
//                    }
//
//                    self.rect = frame
//                    self.point = finalPoint
//
//
//                     print("txtfield:    \(self.txtCopyRight.frame)")
//                     print("point:    \(self.point)")
//
//                }
//            }
    }
    
    func estimatedCenter() -> CGPoint {
        var newCenter:CGPoint!
        var newCenterX = beginningCenter.x + (touchLocation.x - beginningPoint.x)
        var newCenterY = beginningCenter.y + (touchLocation.y - beginningPoint.y)
        if enableMoveRestriction {
            if (!(newCenterX  * self.txtCopyRight.bounds.width > 0 &&
                newCenterX  * self.txtCopyRight.bounds.width < self.imageView.bounds.width)) {
                    newCenterX = self.txtCopyRight.center.x;
                }
            if (!(newCenterY - 0.5 * self.txtCopyRight.bounds.height > 0 &&
                newCenterY + 0.5 * self.txtCopyRight.bounds.height < self.imageView.bounds.height)) {
                newCenterY = self.txtCopyRight.center.y;
            }
            newCenter = CGPoint(x: newCenterX, y: newCenterY)
        } else {
            newCenter = CGPoint(x: newCenterX, y: newCenterY)
        }
        return newCenter;
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint, imgFrame:CGRect) -> UIImage {

        return image.scaledImageWithinRect(rectSize: self.imageView.frame.size, text: text, point: point, imgFrame: imgFrame)

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

extension UITextField {
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //print("check point: \(point)")
        
        return self
    }
}

