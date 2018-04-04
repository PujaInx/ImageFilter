//
//  BaseVC.swift
//  CustomImageFilter
//
//  Created by Intelivex Labs on 27/03/18.
//  Copyright © 2018 Intelivex Labs. All rights reserved.
//

import UIKit
import ZMJImageEditor


extension BaseVC:WBGImageEditorDataSource,WBGImageEditorDelegate {
    
    func imageEditorDefaultColor() -> UIColor! {
        return UIColor.red
    }
    public func imageEditor(_ editor: WBGImageEditor!, didFinishEdittingWith image: UIImage!) {
        self.imageView.image = image;
        editor.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imageEditorDrawPathWidth() -> NSNumber! {
        return 5
    }
    public func imageItemsEditor(_ editor: WBGImageEditor!) -> [WBGMoreKeyboardItem]! {
        return [WBGMoreKeyboardItem.create(byTitle: "p1", imagePath:"p1" , image: #imageLiteral(resourceName: "p1")),
                WBGMoreKeyboardItem.create(byTitle: "p2", imagePath:"p2" , image: #imageLiteral(resourceName: "p2")),
                WBGMoreKeyboardItem.create(byTitle: "p1", imagePath:"p1" , image:#imageLiteral(resourceName: "p1")),
                WBGMoreKeyboardItem.create(byTitle: "p2", imagePath:"p2" , image: #imageLiteral(resourceName: "p2")),
                WBGMoreKeyboardItem.create(byTitle: "p1", imagePath:"p1" , image: #imageLiteral(resourceName: "p1")),
                WBGMoreKeyboardItem.create(byTitle: "p2", imagePath:"p2" , image: #imageLiteral(resourceName: "p2"))
            
        ]
    }

    
    public func imageEditorCompoment() -> WBGImageEditorComponent {
        return WBGImageEditorComponent.wholeComponent;
    }
    
    
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
            self.btnAddCopyright.setTitle("Edit", for: .normal)
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
        
        UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil);        
//        self.imageView.image = self.textToImage(drawText: self.txtCopyRight.text!, inImage: self.imageView.image!, atPoint:self.point, imgFrame: rect)
//        UIImageWriteToSavedPhotosAlbum(self.imageView.image!,self,nil, nil)
//        self.txtCopyRight.isHidden = true
//        self.txtCopyRight.isUserInteractionEnabled = false
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
        
        if ((self.imageView.image) != nil) {
            let editor = WBGImageEditor.init(image: self.imageView.image, delegate: self, dataSource: self)
            self.present(editor!, animated: true, completion: nil)
        } else {
            print("Error");
        }
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
    
//    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint, imgFrame:CGRect) -> UIImage {
//
//        return image.scaledImageWithinRect(rectSize: self.imageView.frame.size, text: text, point: point, imgFrame: imgFrame)
//
//    }
    
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

