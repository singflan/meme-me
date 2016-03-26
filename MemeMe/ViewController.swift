//
//  ViewController.swift
//  MemeMe
//
//  Created by Dustin Flanary on 3/8/16.
//  Copyright © 2016 Dustin Flanary. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    let textDelegate = TextFieldsDelegate()
    let defaultTopText = "TOP"
    let defaultBottomText = "BOTTOM"
    var memedImage: UIImage?

    override func viewDidAppear(animated: Bool) {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        topTextField.defaultTextAttributes = textDelegate.memeTextAttributes
        bottomTextField.defaultTextAttributes = textDelegate.memeTextAttributes
        
        topTextField.text = defaultTopText
        topTextField.textAlignment = NSTextAlignment.Center
        
        bottomTextField.text = defaultBottomText
        bottomTextField.textAlignment = .Center
        
        topTextField.delegate = textDelegate
        bottomTextField.delegate = textDelegate
        
        shareBarButton.enabled = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        // Got help from forum question
        if imagePickerView.image == nil {
            shareBarButton.enabled = false
        } else {
            shareBarButton.enabled = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // When the keyboard is about to show (when editing the bottom textField), the view shifts the amount of the keyboard's height
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // When the keyboard is about to disappear, the frame's origin is set back to 0.
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        /* I got this solution from the discussion board. This is saying that I adjust the screen only when the bottom textField is being edited, not the top one. */
        if bottomTextField.editing {
            return keyboardSize.CGRectValue().height
        } else {
            return 0
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This function sets up the UIImagePickerController and sets the correct sourceType based on the button that was clicked and presents the camera or photo library
    @IBAction func pickImageFromSource (sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        if sender as! NSObject == cameraButton {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareMeme (sender: AnyObject) {
        /* I got help on this part from an answer of a Udacity coach in the forum. It creates a screenshot of the meme that can be shared */
        
        self.memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [self.memedImage!], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage
    {
        self.navBar.hidden = true
        self.bottomToolBar.hidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.navBar.hidden = false
        self.bottomToolBar.hidden = false
        
        return memedImage
    }
    
    // Save the text and image to a Meme struct
    func save() {
        let meme = Meme(top: topTextField.text!, bottom: bottomTextField.text!, image: imagePickerView.image!, meme: generateMemedImage())
    }
}

