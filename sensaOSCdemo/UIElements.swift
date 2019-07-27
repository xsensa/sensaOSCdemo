//
//  UIElements.swift
//  sensaOSCDemo
//
//  Created by User on 2019-07-26.
//  Copyright © 2019 xSensa Labs. All rights reserved.
//

import UIKit

// colors and UIelements

func hexStringToUIColor (_ hex:String, alpha:Float=1.0) -> UIColor {
    var rgbValue:UInt32 = 0
    Scanner(string: hex).scanHexInt32(&rgbValue)
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(alpha)
    )
}

// colors
let brand_aqua = hexStringToUIColor("0DDDD8")
let brand_darknavy = hexStringToUIColor("022053")
let brand_blue = hexStringToUIColor("1177DD")
let brand_red = hexStringToUIColor("FF6A5A")
let brand_green = hexStringToUIColor("5AFF67")


class RoundedButton: UIButton {
    
    var col:UIColor = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.borderColor = col.cgColor
        self.layer.borderWidth = 1
        self.backgroundColor = col
        self.setTitleColor(brand_darknavy, for: .normal)
        self.setTitleColor(col, for: .selected)
        self.tintColor = UIColor.clear
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.titleLabel?.backgroundColor = UIColor.clear
        self.titleLabel?.textAlignment = .center
        self.showsTouchWhenHighlighted = true
    }
    
    func selectBut(_ val:Bool, alpha:CGFloat = 1) {
        self.isSelected = val
        let faintcol = col.withAlphaComponent(alpha)
        self.layer.borderColor = faintcol.cgColor
        self.setTitleColor(faintcol, for: .normal)
        self.setTitleColor(brand_darknavy, for: .selected)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        if val {
            self.backgroundColor = col
        }
        else {
            self.backgroundColor = UIColor.clear
        }
        self.setNeedsDisplay()
    }
}


class userView:UIView {
    var lab:UILabel = UILabel()
    var but:RoundedButton = RoundedButton()
    var col:UIColor = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        // add new user button to the display
        but = RoundedButton(frame:CGRect(x:0,y:0, width:100, height:30))
        but.titleLabel?.font =  UIFont.systemFont(ofSize: 12)
        but.col = col
        but.selectBut(false)
        self.addSubview(but)
        
        lab = UILabel(frame:CGRect(x:but.frame.origin.x + but.frame.width + 3, y:but.frame.origin.y, width: but.frame.width, height:but.frame.height))
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textColor = UIColor.white
        lab.text = "xxx.xxx.xxx.xx"
        self.addSubview(lab)
    }
}
