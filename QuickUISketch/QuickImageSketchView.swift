//
//  QuickImageSketchView.swift
//  Quick Demo For GT
//
//  Created by Matthew Lui on 7/10/2015.
//  Copyright © 2015 goldunderknees. All rights reserved.
//

import UIKit

// Even it's just a quick demo, but urgly is urgly.
// Also, don't use this code directly, it has a little chance to be crashed if someone don't set the property right since I haven't write much protection code here.
@IBDesignable
public class QuickSketchImageView: UIImageView {
    @IBInspectable public var rawImage : UIImage?
    
    public override var image:UIImage? {
        didSet{
            if rawImage === nil{
                rawImage = image
            }
        }
    }
    
    @IBInspectable public var saturation:CGFloat = 1.0{
        didSet{
            if let img = rawImage{
                processThenSetImage(img)
            }
        }
    }
    @IBInspectable public var brightness:CGFloat = 1.0{
        didSet{
            if let img = rawImage{
                processThenSetImage(img)
            }
        }
    }
    
    @IBInspectable public var crop:Bool = false{
        didSet{
            if let img = rawImage{
                processThenSetImage(img)
            }
        }
    }
    
    private func processThenSetImage(img:UIImage){
        let imgToSet = imageDraw(img, process: { (size, scale) -> () in
            self.tuneSaturation(size, saturation: self.saturation)
            self.tuneBrgihtness(size, brightness: self.brightness)
        })
        self.image = imgToSet
    }
    
    private func imageDraw(img:UIImage,process:(size:CGSize,scale:CGFloat)->()) -> UIImage{
        
        let size = img.size
        let scale = img.scale
        let ratio = max(bounds.height/size.height, bounds.width/size.width)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        if crop{
            self.crop(CGSizeMake(size.width*ratio, size.height*ratio))
        }
        if contentMode == UIViewContentMode.ScaleAspectFill{
            img.drawInRect(CGRectMake((size.width*ratio-bounds.width)/2, -((size.height*ratio-bounds.height)/2), size.width*ratio, size.height*ratio))
        }else{
            img.drawInRect(CGRectMake(0, 0, size.width*ratio, size.height*ratio))
        }
        
        process(size: bounds.size, scale: scale)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        return output
    }
    
    // How urgly the code is!!!!!!!!!!!
    private func tuneSaturation (size:CGSize,saturation:CGFloat){
        let bounds = CGRectMake(0, 0, size.width, size.height)
        UIColor(white: 1.0, alpha: 1.0-saturation).set()
        UIRectFillUsingBlendMode(bounds, CGBlendMode.Color)
    }
    private func tuneBrgihtness (size:CGSize,brightness:CGFloat){
        let bounds = CGRectMake(0, 0, size.width, size.height)
        UIColor(white: 0, alpha: 1-brightness).set()
        UIRectFillUsingBlendMode(bounds, CGBlendMode.PlusDarker)
    }
    
    private func crop (size:CGSize){
        let bounds = CGRectMake(0, 0, size.width, size.height)
        UIBezierPath(ovalInRect: bounds).addClip()
    }
    
    override public func prepareForInterfaceBuilder() {
        processThenSetImage(rawImage!)
    }
}

//I don't know the girl, don't ask me for that.