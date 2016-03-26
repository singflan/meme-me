//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Dustin Flanary on 3/8/16.
//  Copyright © 2016 Dustin Flanary. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    
    var navigationBarHidden: Bool!
    
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    let textDelegate = TextFieldsDelegate()
    let defaultTopText = "TOP"
    let defaultBottomText = "BOTTOM"
    var memedImage: UIImage?

// MARK: - Lifecycle Functions
    
    override func viewDidAppear(animated: Bool) {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = false
        setupTextFields(topTextField)
        setupTextFields(bottomTextField)
        shareBarButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        // Got help from a forum question; this makes the share button unavailable until an image is picked.
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

// MARK: - Setup
    // This sets up the TextFields with the delegate file and assigns them the default text, attributes and alignment
    func setupTextFields (textField: UITextField) {
        textField.defaultTextAttributes = textDelegate.memeTextAttributes
        textField.textAlignment = .Center
        textField.delegate = textDelegate
        if textField == topTextField {
            textField.text = defaultTopText
        } else {
            textField.text = defaultBottomText
        }
    }
    
// MARK: - Keyboard Functions
    
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
        self.view.frame.origin.y = 0
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
    
// MARK: - Actions
    
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
            imagePickerView.contentMode = .ScaleAspectFit
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareMeme (sender: AnyObject) {
        /* I got help on this part from an answer of a Udacity coach in the forum. It creates a screenshot of the meme that can be shared */
        memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [self.memedImage!], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage
    {
        // Hide Navigation Bar and Toolbar for screenshot
        navigationController?.setNavigationBarHidden(true, animated:  true)
        bottomToolBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Have Navigation Bar and toolbar reappear immdiately after screenshot is taken
        navigationController?.setNavigationBarHidden(false, animated: true)
        bottomToolBar.hidden = false
        
        return memedImage
    }
    
    // Save the text and image to a Meme struct
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, origImage: imagePickerView.image!, memeImage: generateMemedImage())
    }
}

