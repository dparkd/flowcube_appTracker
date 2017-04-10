//
//  AppDelegate.swift
//  Quotes
//
//  Created by Daniel Park on 2017-03-30.
//  Copyright © 2017 Daniel Park. All rights reserved.
//

import Cocoa
import Foundation
import AppKit

// application declarations
var workspace = NSWorkspace.sharedWorkspace()
var applications = workspace.runningApplications
var timer = NSTimer()
var mostRecent = ""
var timeCounter = 0


@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let popover = NSPopover()
    
    // Timer
    func scheduledTimerWithTimeInterval(){
        // Run the UpdateCounting() function on a timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateCounting"), userInfo: nil, repeats: true)
    }
    
    func updateCounting(){
        for app in applications {
            if (app.active) {
                if (app.localizedName! == "Google Chrome") {
                    timeCounter += 1
                    print(timeCounter)
                    
                    if (timeCounter > 5) {
                        showNotification()
                        makeHTTPrequest()
                        timeCounter = 0
                    }
                }
                print(app.localizedName)
            }
        }
    }
    
    // Main Code
    func showPopover(sender: AnyObject?) {
        if let _ = statusItem.button {
            scheduledTimerWithTimeInterval()
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    func applicationDidFinishLaunching(notification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = Selector("togglePopover:")
        }
        popover.contentViewController = QuotesViewController(nibName: "QuotesViewController", bundle: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    // Show notification
    func showNotification() -> Void {
        let notification = NSUserNotification()
        notification.title = "Flow Cube"
        notification.informativeText = "It's time to take an intentional mindful break"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
    
    // Make the request to my local server
    func makeHTTPrequest() -> Void {
        // HTTP declarations
        let request = NSMutableURLRequest(URL: NSURL(string: "http://149.31.136.227:3000/break-time")!)
        request.HTTPMethod = "POST"
        let postString = "light=true"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
        }
        task.resume()
    }


}

