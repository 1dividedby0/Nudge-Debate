//
//  ProfileViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 1/11/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var imagePicker: UIImagePickerController!
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        if ((PFUser.current()!.object(forKey: "profile_pic") as? PFFile) != nil){
            let file = PFUser.current()!.object(forKey: "profile_pic") as! PFFile
            //file.delete(self)
            print(file)
            file.getDataInBackground({ (data, error) -> Void in
                let image = UIImage(data: data!)
                self.profileImageView.image = UIImage(cgImage: (image?.cgImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.right)
            })
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func editProfileImage(_ sender: AnyObject) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        print(UIImagePickerController.isSourceTypeAvailable(.camera))
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let imageData = UIImageJPEGRepresentation(image!, 0.9)
        let imageFile = PFFile(data: imageData!)
        PFUser.current()!.setObject(imageFile!, forKey: "profile_pic")
        PFUser.current()!.saveInBackground { (success, error) in
            self.profileImageView.image = image
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
