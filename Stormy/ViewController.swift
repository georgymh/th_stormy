//
//  ViewController.swift
//  Stormy
//
//  Created by Georgy Marrero on 12/29/14.
//  Copyright (c) 2014 Georgy Marrero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    
    private let apiKey = "FORECAST.IO KEY"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshActivityIndicator.hidden = true
        getCurrentWeatherData()
    }
    
    func stopRefreshAnimation() -> Void {
        // Stop refresh animation
        self.refreshActivityIndicator.stopAnimating()
        self.refreshActivityIndicator.hidden = true
        self.refreshButton.hidden = false
    }
    
    func getCurrentWeatherData() -> Void {
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        
        let forecastURL = NSURL(string: "34.775818,-119.896067", relativeToURL: baseURL) // Orange, CA
        
        let sharedSession = NSURLSession.sharedSession()
        
        // entering thread X
        let downloadTask: NSURLSessionDownloadTask =
            sharedSession.downloadTaskWithURL(forecastURL!,
            completionHandler: { (location: NSURL!, response:
            NSURLResponse!, error: NSError!) -> Void in
                
                if (error == nil) {
                    let dataObject = NSData(contentsOfURL: location)
                    let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as
                    NSDictionary
                    
                    let currentWeather = Current(weatherDictionary: weatherDictionary)
                    
                    // a dispatch
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.temperatureLabel.text = "\(currentWeather.temperature)"
                        self.iconView.image = currentWeather.icon!
                        self.currentTimeLabel.text = "At \(currentWeather.currentTime!) it is"
                        self.humidityLabel.text = "\(currentWeather.humidity)"
                        self.precipitationLabel.text = "\(currentWeather.precipProbability)"
                        self.summaryLabel.text = "\(currentWeather.summary)"
                        
                        self.stopRefreshAnimation()
                    })
                } else {
                    let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data. Conectivity Error.", preferredStyle: .Alert)
                    
                    let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    networkIssueController.addAction(okButton)
                    
                    let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                    networkIssueController.addAction(cancelButton)
                    
                    self.presentViewController(networkIssueController, animated: true, completion: nil)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // Stop refresh animation
                        self.stopRefreshAnimation()
                    })
                }
        })  // out of thread X
        
        downloadTask.resume()
        
        //Ignore from here -------------------
        //DONT DO IT LIKE THIS, REMEMBER THE LANES ANALOGY: ANOTHER THREAD
        //let weatherData = NSData(contentsOfURL: forecastURL!, options: NSDataReadingOptions(), error: NSErrorPointer())
        //println(weatherData)
    }
    
    @IBAction func refresh() {
        getCurrentWeatherData()
        
        refreshButton.hidden = true
        refreshActivityIndicator.hidden = false
        refreshActivityIndicator.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

