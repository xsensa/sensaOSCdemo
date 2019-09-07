//
//  OSCDemoGlobals.swift
//  sensaOSCDemo
//
//  Created by User on 2019-07-17.
//  Copyright © 2019 xSensa Labs. All rights reserved.
//

import UIKit
import SwiftOSC


// global variables

var servers:[OSCServer] = [] // will create sevaral listening servers for incoming OSC messages at different ports
var users:[String] = [] // list of users
var senders:[String] = [] // list of ip addresses of users

var users_last_time:[Date] = [] // for each user we record last time we receive message, so we knwo who is active

var thisIP:String = "" // IP address of the device running this app

var networks:[String] = ["Flow","Calm","Focus","Cognitive"] // Names of 4 brain networks detected by xSensa's brain engine

var hubActivity:[[String]] = [[String]]() // nework activity of all users in the hub
// Example: 5 users, activity of Flow network across all users: hubActivity[0] = "21 52 12 56 11"

var smoothing_kernel:String = "3"

//////////////// utility functions



