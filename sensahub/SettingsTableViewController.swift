//
//  OSCSettingsTableViewController.swift
//  sensaOSC
//
//  Created by User on 2019-07-16.
//  Copyright © 2019 xSensa Labs. All rights reserved.
//


import UIKit
import AVFoundation
import SwiftOSC

class SettingsTableViewController: UITableViewController{
    
    var cellIdentifier: String = "oscsettingcell"
    
    var blurItems: [String] = ["0.5","1","2","3","4","5","10"] // diffrent options depneding on training are set in viewDidLoad
    var sections:[String] = ["Smoothing kernel (in seconds)"]
    
    //array of tuples for selected cells
    var selectedCells:[(row: Int, section: Int)] = []
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        
        super.viewDidLoad()
        
        populateSelectedCells()
    }
    
    func populateSelectedCells() {
        var count:Int = 0
        if sections.contains("Smoothing kernel (in seconds)") {
            if let row = blurItems.firstIndex(of: smoothing_kernel) {
                selectedCells.append((row,count))
            }
            else {
                selectedCells.append((0,count))
            }
        }
    }
    
    override func viewWillDisappear(_ animated:Bool) {
        super.viewWillDisappear(animated)
        // send notification to any class that is listening for changes in Settings
        // NotificationCenter.default.post(name: Notification.Name(rawValue: "settingsChanged"), object: nil, userInfo: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sections.count {
            return sections[section]
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // This changes the header background
        view.tintColor = brand_darknavy
        
        // Gets the header view as a UITableViewHeaderFooterView and changes the text colour
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case "Smoothing kernel (in seconds)":
            return blurItems.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)as UITableViewCell
        
        let row = (indexPath as NSIndexPath).row
        let section = (indexPath as NSIndexPath).section
        if selectedCells[section].section==section && selectedCells[section].row==row {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        switch sections[section] {
        case "Smoothing kernel (in seconds)":
            cell.textLabel?.text = blurItems[row]
        default:
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    func resetChecks(_ tableView: UITableView,section: Int) {
        for i in 0...tableView.numberOfRows(inSection: section)-1 {
            if let cell = tableView.cellForRow(at: IndexPath(row: i, section: section))
            {
                cell.accessoryType = .none
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // when user selects a particular row
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = (indexPath as NSIndexPath).section
        if let cell = tableView.cellForRow(at: indexPath)  {
            resetChecks(tableView,section: section)
            selectedCells[section] = ((indexPath as NSIndexPath).row, section)
            cell.accessoryType = .checkmark
            switch sections[section] {
            case "Smoothing kernel (in seconds)":
                smoothing_kernel = (cell.textLabel?.text)!
                // broadcast new smoothing kernel to all users
                for i in 0..<users.count {
                    let clientOSC = OSCClient(address: senders[i], port: 9000) // outgoing OSC
                    let address = OSCAddressPattern("/buflensec/")
                    print("sending message \(address) \(smoothing_kernel)")
                    clientOSC.send(OSCMessage(address,smoothing_kernel))
                }
            default:
                print("no valid section in selected cell")
            }
        }
    }
    
}
