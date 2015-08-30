//
//  ViewController.swift
//  http2test
//
//  Created by Florian Goessler on 29/08/15.
//  Copyright © 2015 Florian Gößler. All rights reserved.
//

import UIKit

class ViewController: UIViewController, HTTP2TesterDelegate {

	let http2Tester = HTTP2Tester()
	lazy var dateFormatter: NSDateFormatter = {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
		dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
		return dateFormatter
	}()
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var logTextView: UITextView!
	
	@IBAction func startTest(sender: AnyObject) {
		http2Tester.delegate = self
		
		// update UI
		startButton.setTitle("Running...", forState: .Normal)
		startButton.enabled = false
		logTextView.text = ""
		statusLabel.text = "Starting..."
		
		// start requests
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
			// send single test requests to test that NSURLSession actually uses HTTP/2 and NSURLConnection uses HTTP 1.1
			self.http2Tester.sendHTTP2TestRequest(.NSURLConnection)
			self.http2Tester.sendHTTP2TestRequest(.NSURLSession)
			
			// send multiple requests at once to demonstrate the advantage of HTTP/2
			self.http2Tester.sendMultipleHTTPRequests(.NSURLConnection)
			self.http2Tester.sendMultipleHTTPRequests(.NSURLSession)
			
			// update UI after finishing the requests
			dispatch_async(dispatch_get_main_queue()) {
				self.statusLabel.text = "Finished"
				self.logTextView.text = "[\(self.dateFormatter.stringFromDate(NSDate()))]: Finished\n\(self.logTextView.text)"
				self.startButton.setTitle("Restart it!", forState: .Normal)
				self.startButton.enabled = true
			}
		}
	
	}
	
	func http2Tester(http2Tester: HTTP2Tester, notifiesAboutEvent msg: String) {
		NSLog(msg)
		dispatch_async(dispatch_get_main_queue()) {
			self.statusLabel.text = msg
			self.logTextView.text = "[\(self.dateFormatter.stringFromDate(NSDate()))]: \(msg)\n\(self.logTextView.text)"
		}
	}
}

