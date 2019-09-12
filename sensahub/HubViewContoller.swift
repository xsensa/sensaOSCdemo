//
//  OSCDemoHomeViewContoller.swift
//  sensaOSCDemo
//
//  Created by User on 2019-07-09.
//  Copyright © 2019 xSensa Labs. All rights reserved.
//

import Foundation

import UIKit
import SwiftOSC

class HubViewController: UIViewController, OSCServerDelegate , UIPopoverPresentationControllerDelegate  {
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated:true)
    }
    
    
    @IBOutlet weak var RecevingLab: UILabel!
    
    var userviews:[userView] = [] // buttons + ipaddress, one per user. New userView appaears as soon as we receive osc message with correct format
    var broadcastTimer = Timer() // timer for sending data from the hub to active users
    let sh = UIScreen.main.bounds.size.height
    
    @IBOutlet weak var barGraphView: DynamicBarGraphView! // bargraph shows live stream for the selected user
    
    @IBOutlet weak var Message: UILabel!
    
    @IBOutlet weak var settingsBut: RoundedButton!
    @IBAction func onSettings(_ sender: Any) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "main", bundle: nil)
        let destination = storyboard.instantiateViewController(withIdentifier:  "SettingsTableViewController") as! SettingsTableViewController
        let nav = UINavigationController(rootViewController: destination)
        nav.modalPresentationStyle = .popover
        let popover = nav.popoverPresentationController
        destination.preferredContentSize = CGSize(width:300,height:sh*0.6)
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        nav.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        present(nav, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        settingsBut.col = UIColor.white
        settingsBut.selectBut(false)
        
        barGraphView.parent_ctrl = self
        barGraphView.init_bars(true)
        
        // start listening on all ports
        for i in 0..<15 {
            let server = OSCServer(address: "", port: 9061+i)
            server.delegate = self
            server.start()
            servers.append(server)
        }
        
        // broadcast hub values to all users in regular intervals
        broadcastTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(broadcast_hub), userInfo: nil, repeats: true)
        broadcastTimer.tolerance = 0.1
        
    }
    
    @objc func broadcast_hub() {
        let nowDate = Date()
        
        // determine which users are active
        for i in 0..<users.count {
            let val = nowDate.timeIntervalSince(users_last_time[i]) // in seconds
            if val > 5 { // if we haven't heard from this user for 2 seconds, he is no longer active
                userviews[i].alpha = 0.2
            }
        }
       
        var hubNetMsgs = Array(repeating: "", count: networks.count) // hubActivity[nework][user]
        for n in 0..<networks.count {
            for i in 0..<userviews.count{
                if userviews[i].alpha > 0.3  { // take current network values data from active users
                    hubNetMsgs[n] += " \(senders[i]),\(hubActivity[n][i])"
                }
            }
        }
        
        for i in 0..<userviews.count {
            if userviews[i].alpha > 0.3  { // broadcast to active users only
                let clientOSC = OSCClient(address: senders[i], port: 9000) // outgoing OSC
                for n in 0..<networks.count {
                    let address = OSCAddressPattern("/hub\(networks[n])/")
                    clientOSC.send(OSCMessage(address,hubNetMsgs[n]))
                }
            }
        }
        
    }
    
    func synchronized<T>(_ lock: [String:String], closure: () throws -> T) rethrows -> T {
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }
        return try closure()
    }
    
    //implement OSC server delegate function. what to do when we receive OSC message
    func didReceive(_ message: OSCMessage) {
        
        let brainval = message.arguments[0] as! String
        let addr = message.address.string
        
        //print("received \(addr) \(brainval)")
        // expected format of the address; /sender_ip/username/brain_network
        // example: /192.168.1.135/gugu/Cognitive/
        let arr = addr.split(separator:"/")
        if arr.count != 3 {
            let alertController = UIAlertController(title: "Received garbled message", message:
                "\(addr) \(brainval)" , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        let sender_ip:String = String(arr[0])
        let username:String = String(arr[1])
        let brain_network:String = String(arr[2])
        
        if let netindex = networks.firstIndex(of: brain_network) {
            barGraphView.username = username
            barGraphView.useraddress = "/\(sender_ip)/\(username)/"
            var userindex:Int = -1
            if !senders.contains(sender_ip) { // add new user
                users.append(username)
                senders.append(sender_ip)
                users_last_time.append(Date())
                userindex = users.count - 1
                for n in 0..<networks.count {
                    hubActivity[n].append("")
                }
                
                // broadcast temporal smoothing kernel to new user
                let clientOSC = OSCClient(address: senders[userindex], port: 9000) // outgoing OSC
                let address = OSCAddressPattern("/buflensec/")
               
                clientOSC.send(OSCMessage(address,smoothing_kernel))
                
                // add new user button to the display
                let userview = userView(frame:CGRect(x:RecevingLab.frame.origin.x,y:RecevingLab.frame.origin.y + RecevingLab.frame.height + 20 + CGFloat(users.count-1)*0.1*sh, width:200, height:30))
                userview.but.setTitle(username, for: .normal)
                userview.but.tag = users.count - 1
                userview.but.addTarget(self, action: #selector(selectUser), for: .touchUpInside)
                userview.lab.text = sender_ip
                userview.alpha = 1
                userviews.append(userview)
                view.addSubview(userview)
            }
            else { // we have this user
                // if user is selected, update bar graph
                userindex = senders.firstIndex(of: sender_ip)!
                users_last_time[userindex] = Date()
                let userview = userviews[userindex]
                userview.alpha = 1
                if userview.but.isSelected { // update graph
                    if brainval != "NaN" {
                        barGraphView.redrawBar(i: netindex, yval:Float(brainval)!)
                    }
                }
            }
            hubActivity[netindex][userindex] = brainval
        }
        else {
            let alertController = UIAlertController(title: "Received garbled message", message:
                "\(addr) \(brainval)" , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
    }
    
    @objc func selectUser(sender: RoundedButton) {
        sender.selectBut(true)
        for i in 0..<userviews.count {
            if i != sender.tag {
                userviews[i].but.selectBut(false)
            }
        }
    }
   
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
    
}

