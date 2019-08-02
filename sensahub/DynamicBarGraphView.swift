//
//  DynamicBarGraphView.swift
//  sensaOSCDemo
//
//  Created by User on 2019-07-09.
//  Copyright © 2019 xSensa Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class DynamicBarGraphView: UIView {

    var parent_ctrl:HubViewController?
    var num_bands = 10
    
   
    var colors:[UIColor] = [brand_aqua, brand_blue, brand_red, brand_green] // network colors
    
    var xoffset:CGFloat = 0
    var yoffset:CGFloat = 0
    
    var useraddress:String = "" // OSC message addresses from currently displaying user
    var username:String = "" // currently displayng user
    
    var bars:[UIButton] = [UIButton]()
    var barwidth:CGFloat = 0
    var maxbarheight:CGFloat = 0
    

    var with_calib = false
     
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func init_bars(_ wcal:Bool) {
        self.with_calib = wcal

        num_bands = networks.count
        
        maxbarheight = 0.6*frame.height
        xoffset = 0
        yoffset = 0.1*frame.height
        
        barwidth = 0.9*frame.width/CGFloat(networks.count)
        let delta = (frame.width - xoffset - barwidth*CGFloat(networks.count)) / CGFloat(networks.count)// space between bars
        for i in 0..<networks.count {
            
            let rec = with_calib ? UIButton(frame:CGRect(x:xoffset,y:yoffset+0.5*maxbarheight, width:barwidth, height:0)) : UIButton(frame:CGRect(x:xoffset,y:yoffset, width:barwidth, height:maxbarheight))
            rec.backgroundColor = colors[i].withAlphaComponent(0.7)
            rec.addTarget(self, action: #selector(touchBarAction), for: .touchUpInside)
            rec.tag = i
            bars.append(rec);
            
            let ylev = self.with_calib ? (yoffset + maxbarheight*0.5 - 5):(yoffset + maxbarheight + 10);
            
           self.CreateLabel( networks[i], frame:CGRect(x:xoffset,y:ylev,width:barwidth,height:50))
            
            self.addSubview(bars[i])
            
            xoffset += barwidth + delta
        }
    }
    
    @objc func touchBarAction(sender: UIButton!) {
        var showtext = ""
        var title = ""
        switch sender.tag {
        case 0:
            title = "Flow"
            showtext = "Flow network supports creative visualization and brings subconcious to the foregorund. Activating this network for 10-15 minutes per day improves mood, creativity and motivation.\n\nCurrently displaying user :\(username)\n\nOSC message address:\n\(useraddress)/Flow/"
        case 1:
            title = "Calm"
            showtext = "Calm network is associated with several types of meditation. Activating this network on a daily basis builds resilience to stress and anxiety.\n\nCurrently displaying user :\(username)\n\nOSC messages at address:\n\(useraddress)Calm/"
        case 2:
            title = "Focus"
            showtext = "Focus network is required for external focus and completing tasks. Exercising this network improves attetnion and concentration.\n\nDisplaying OSC messages address:\n\(useraddress)Focus/"
        case 3:
            title = "Cognitive"
            showtext = "Frontal cognitive network is involved in higher order mental functions such as memory, decision making, and problem solving. Strenghtning this network thorugh daily practice makes you sharper.\n\nDisplaying OSC messages address:\n\(useraddress)Cognitive/"
        default:
            break
        }
        
        let alertController = UIAlertController(title: title, message:
            showtext , preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
        self.parent_ctrl?.present(alertController, animated: true, completion: nil)

    }

    
    func redrawBars( yvals:[Float]) {
        for i in 0..<networks.count {
            redrawBar(i:i, yval:yvals[i]) 
        }
    }
    
    func redrawBar(i:Int, yval:Float) { // yval is expected to be % value, number between 0 and 100
        
        if with_calib {
            let val = CGFloat(yval/100-0.5)*self.maxbarheight
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                if val > 0 {
                    self.bars[i].frame = CGRect(x:self.bars[i].frame.origin.x,y:self.yoffset + 0.5*self.maxbarheight - val, width:self.bars[i].frame.width, height:abs(val))
                }
                else {
                    self.bars[i].frame = CGRect(x:self.bars[i].frame.origin.x,y:self.yoffset + 0.5*self.maxbarheight, width:self.bars[i].frame.width, height:abs(val))
                }
            }, completion: nil)
        }
        else {
            let yscale =  CGFloat(yval/100)
            let scale = CGAffineTransform(scaleX: 1.0, y: yscale)
            let yshift = maxbarheight*(1-yscale)/CGFloat(2)
            let translate = CGAffineTransform(translationX: 0, y:yshift)
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { self.bars[i].transform = scale.concatenating(translate)}, completion: nil)
        }
    }
    
    func CreateLabel(_ name: String, frame: CGRect) -> UILabel {
        if (frame.origin.x.isNaN) || (frame.origin.y.isNaN) { return UILabel()}
        let Lab = UILabel(frame: frame)
        Lab.text = name
        Lab.textColor = UIColor.white
        Lab.backgroundColor = UIColor.clear
        Lab.textAlignment = .center
        Lab.numberOfLines = 2
        Lab.font = UIFont.systemFont(ofSize:11)
        self.addSubview(Lab)
        return Lab
    }
    
     override func draw(_ rect: CGRect) {
        yoffset = /*with_calib ? 0.7*frame.height :*/ 0.1*frame.height
        // network is considered active if value is > 50%
        // here we draw threshold line at 50%
        drawHorizontalLine(self.frame, yh:self.yoffset + 0.5*self.maxbarheight, lineWidth:1)
    }
    
    func drawHorizontalLine(_ rect: CGRect, yh: CGFloat, lineWidth:CGFloat = 2) {
        // yh should be fraction of the height, e.g. 0.5 for midline
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x:0,y:yh))
        linePath.addLine(to: CGPoint(x:rect.width,y:yh))
        
        let color = UIColor.white
        color.setStroke()
        
        linePath.lineWidth = lineWidth
        // let pattern: [CGFloat] = [3.0, 1]
        // linePath.setLineDash(pattern, count: 2, phase: 0.0)
        
        linePath.stroke()
    }
}
