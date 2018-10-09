//
//  ViewController.swift
//  Hangman
//
//  Created by fsociety.1 on 2/25/18.
//  Copyright © 2018 fsociety.1. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

class MainVC: UIViewController {

    @IBOutlet weak var playBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBTN.layer.cornerRadius = 10
        playBTN.layer.borderWidth = 1
        playBTN.layer.borderColor = UIColor.white.cgColor
        playBTN.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        getWords()
        checkForUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getWords() {
        let url = "https://hangonman.herokuapp.com"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            do {
                let json = JSON(response.value)
                
                let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] .appendingPathComponent("Words.json")
                
                if let data = try? json.rawData() {
                    try? data.write(to: fileUrl)
                }
                
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
        }
    }
    
    
    
    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        print(currentVersion)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                completion(version != currentVersion, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    func checkForUpdate() {
        _ = try? isUpdateAvailable { (update, error) in
            if let error = error {
                print(error)
            } else if let update = update {
                print(update)
                if update {
                    let alert = UIAlertController(title: "New Version Found", message: "A new version of this app is available. \nWant to download it now?", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1366396345"),
                            UIApplication.shared.canOpenURL(url){
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}

