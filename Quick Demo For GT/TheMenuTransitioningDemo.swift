//
//  ViewController.swift
//  Quick Demo For GT
//
//  Created by Matthew Lui on 6/10/2015.
//  Copyright © 2015 goldunderknees. All rights reserved.
//

import UIKit

//MARK: All class are defined here for quick viewing.
class ViewController: UIViewController{

    ///The two states is for quick development use only, don't code like that if you don't want your codes like a mess, use a center control instead!
    private var showingMenu             = false
    private var willDismiss             = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        if showingMenu {
            dismissMenu()
        }
    }
    
    private var beginningTouchLocation  = CGPointZero
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            beginningTouchLocation = touch.locationInView(view)
        }
    }
    
    // The iOS9 introduce a better touch checking mechanism so, forget this code it's for a quick demo only.
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches{
            //If any one don't know what you are doing and override this method in there subclass without calling the super class to perform this method, what will happen?
            if !showingMenu || willDismiss{
                return
            }
            let cur = touch.locationInView(view)
            guard let touchView = navigationController?.view else{
                return
            }
            updateOverlayView(to: cur.x - beginningTouchLocation.x + touchView.frame.minX, overlayView: touchView)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // What if your other team member don't know how this checking necessary is?
        if showingMenu && !willDismiss{
            guard let touchView = navigationController?.view else{
                return
            }
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.updateOverlayView(to: 220, overlayView: touchView)
            })
        }
    }

    // Predict if the real app using Interface Builder rather than ViewControllerTransitioning mechanism.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "MainMenuControlSegue" {
            let customSegua = segue as! OverlayMenuSegue
            if showingMenu {
                customSegua.event = .DissmisMenu
                showingMenu = false
                willDismiss = true
            }else{
                customSegua.event = .ShowMenu
                customSegua.completion = { self.willDismiss = false }
                showingMenu = true
                segueCache = segue
            }
        }
        
    }
    
    /// A convenience way to row back only, not a good practise!!!
    private var segueCache  :UIStoryboardSegue?
    func dismissMenu(){
        guard let segue = segueCache else{
            return
        }
        willDismiss = true
        prepareForSegue(segue, sender: self)
        segue.perform()
    }
    
    //MARK: Don't hard code the animation!!!!!!!!!!!!!!
    func transform(delta x:CGFloat,of subview:UIView){
        let transform = CGAffineTransformConcat(subview.transform, CGAffineTransformMakeTranslation(  -x, 0))
        subview.transform = CGAffineTransformScale(transform, 1 + x * ( 0.3 / 1 / 200), 1 + x * ( 0.3 / 1 / 200))
    }
    
    //MARK: Don't hard code the animation!!!!!!!!!!!!!!
    func updateOverlayView(to x:CGFloat, overlayView:UIView){
        if willDismiss{
            return
        }else if overlayView.frame.height > view.frame.height * 0.95{
            dismissMenu()
            return
        }
        let xDelta = (220 - x) / 1000
        let transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(220 - 500 * xDelta, 0), CGAffineTransformMakeScale( 0.8 + xDelta, 0.8 + xDelta))
        overlayView.transform = transform
    }

}

//MARK: Custom Segue
class OverlayMenuSegue:UIStoryboardSegue {
    
    enum SegueEvent{
        case ShowMenu
        case DissmisMenu
    }
    var event:SegueEvent = .ShowMenu
    
    override func perform() {
        switch event{
        case .ShowMenu:
            show()
        case .DissmisMenu:
            dissmis()
        }
    }
    var completion:()->() = {}
//  Be aware, don't hard code the animation in the real production evironment!  It's just a demo!!
    func show(){
        
        let menuVC = destinationViewController
        let mainVC:UIViewController
        
        if let viewcontroller = sourceViewController.navigationController{
            mainVC = viewcontroller
        }else{
            mainVC = sourceViewController
        }
        
        let mainVCView = mainVC.view
        
        guard let window = UIApplication.sharedApplication().keyWindow else{
            return
        }
        window.insertSubview(menuVC.view, atIndex: 0)
        
        mainVCView.layer.shadowOpacity = 1
        mainVCView.layer.shadowRadius = 10
        mainVCView.removeFromSuperview()
        menuVC.view.addSubview(mainVCView)
        
        // Just a rough animation there.
        UIView.animateKeyframesWithDuration(0.6, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModeCubic, animations: { () -> Void in
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5, animations: { () -> Void in
                var transform = CGAffineTransformMakeTranslation(200, 0)
                transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(0.8, 0.8))
                mainVCView.transform = transform
            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.45, animations: { () -> Void in
                var transform = CGAffineTransformMakeTranslation(245, 0)
                transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(0.8, 0.8))
                mainVCView.transform = transform
            })
            UIView.addKeyframeWithRelativeStartTime(0.95, relativeDuration: 0.05, animations: { () -> Void in
                var transform = CGAffineTransformMakeTranslation(220, 0)
                transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(0.8, 0.8))
                mainVCView.transform = transform
            })
            }) { (f) -> Void in
                if f{
                    self.sourceViewController.addChildViewController(menuVC)
                    self.completion()
                }

        }

    }
    
    func dissmis(){
        let menuVC = sourceViewController.childViewControllers.first!
        let mainVC:UIViewController
        if let viewcontroller = sourceViewController.navigationController{
            mainVC = viewcontroller
        }else{
            mainVC = sourceViewController
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            mainVC.view.transform = CGAffineTransformIdentity
            })
            { (f) -> Void in
                if f{
                    guard let window = UIApplication.sharedApplication().keyWindow else{
                        return
                    }
                    mainVC.view.frame = mainVC.view.bounds
                    menuVC.view.removeFromSuperview()
                    window.insertSubview(mainVC.view, atIndex: 0)
                    menuVC.removeFromParentViewController()
                    self.completion()
                }
        }
    }
}

//MARK: Draft of MenuViewController
class MenuViewController:UIViewController{
    private var configs             : [String] = ["Users","Watch","It"]
    @IBOutlet weak var configsTable : UITableView!
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(childViewControllers)
    }
}

extension MenuViewController:UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configs.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConfigCell", forIndexPath: indexPath)
        cell.textLabel?.text = configs[indexPath.row]
        return cell
    }
}