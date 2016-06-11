//
//  ResearchViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 11/28/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import UIKit

class ResearchViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        let url = NSURL(string: "http://google.com")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request) 
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stopAction(sender: AnyObject) {
        webView.stopLoading()
    }
    @IBAction func refreshAction(sender: AnyObject) {
        webView.reload()
    }
    @IBAction func rewindAction(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func fastForwardAction(sender: AnyObject) {
        webView.goForward()
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
