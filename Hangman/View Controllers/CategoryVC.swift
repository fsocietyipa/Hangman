//
//  categoryVC.swift
//  Hangman
//
//  Created by fsociety.1 on 2/26/18.
//  Copyright © 2018 fsociety.1. All rights reserved.
//

import UIKit

class CategoryVC: UIViewController {
 
    var setWordType = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GameVC
        {
            let vc = segue.destination as? GameVC
            vc?.wordsType = setWordType
        }
    }
    
    @IBAction func setCategory(_ sender: UIButton) {
        setWordType = sender.currentTitle!
        performSegue(withIdentifier: "showGame", sender: self)
        
    }
    
    @IBAction func back(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        self.present(vc, animated: false, completion: nil)
    }
    
}
