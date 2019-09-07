//
//  InitViewController.swift
//  sensaOSCDemo
//
//  Created by User on 2019-07-17.
//  Copyright © 2019 xSensa Labs. All rights reserved.
//
import UIKit

class InitViewController: UIViewController,UIPopoverPresentationControllerDelegate {
    
    @IBAction func onAbout(_ sender: Any) {
        
        
       let msg = "Let users interact with your beautiful installations and apps using their brains.\n\nxSensa's powerful brain engine detects activation of 4 major networks in the brain. This demo app illustrates how to recieve live activation data from individual users over the internet."
        
        let alertController = UIAlertController(title: "Attention artists and developers!", message: msg, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onLearn(_ sender: Any) {
       
       let msg = "Instruct your users to download xsensaOSC app from the appstore (currently iOS only). Give each user your IP address and a listening port. For example, this demo app listens on ports 9061,...,9076.\n\nDifferent users can send to the same port, but at this time we don't know how performance is affected if large number of users send to the same port. And that's all you need.\n\nFor more information contact info@xsensalabs.com"
        let alertController = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var MsgLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        // initialize, format: hubActivity[nework][user]
        hubActivity = Array(repeating: (Array(repeating: "", count: 0)), count: networks.count)
       
        if let tmp = getIPAddressForCellOrWireless() {
            thisIP = tmp
            MsgLab.text = "This IP address is:\n\n\(thisIP)"
        }
            
        else { // we could not find ip address, so we issue warning
            let alertController = UIAlertController(title: "WiFI info missing", message:
                "We could not find IP address of this device. Please make sure you are connected to internet" , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    

    // determine device's own ip address
    func getIPAddressForCellOrWireless()-> String? {
        
        let WIFI_IF : [String] = ["en0"]
        let KNOWN_WIRED_IFS : [String] = ["en2", "en3", "en4"]
        let KNOWN_CELL_IFS : [String] = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
        
        var addresses : [String : String] = ["wireless":"",
                                             "wired":"",
                                             "cell":""]
        
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next } // memory has been renamed to pointee in swift 3 so changed memory to pointee
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    if let name: String = String(cString: (interface?.ifa_name)!), (WIFI_IF.contains(name) || KNOWN_WIRED_IFS.contains(name) || KNOWN_CELL_IFS.contains(name)) {
                        
                        // String.fromCString() is deprecated in Swift 3. So use the following code inorder to get the exact IP Address.
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                        if WIFI_IF.contains(name){
                            addresses["wireless"] =  address
                        }else if KNOWN_WIRED_IFS.contains(name){
                            addresses["wired"] =  address
                        }else if KNOWN_CELL_IFS.contains(name){
                            addresses["cell"] =  address
                        }
                    }
                    
                }
            }
        }
        freeifaddrs(ifaddr)
        
        var ipAddressString : String?
        let wirelessString = addresses["wireless"]
        let wiredString = addresses["wired"]
        let cellString = addresses["cell"]
        if let wirelessString = wirelessString, wirelessString.count > 0{
            ipAddressString = wirelessString
        }else if let wiredString = wiredString, wiredString.count > 0{
            ipAddressString = wiredString
        }else if let cellString = cellString, cellString.count > 0{
            ipAddressString = cellString
        }
        return ipAddressString
    }

}

