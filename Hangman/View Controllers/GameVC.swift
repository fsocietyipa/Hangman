//
//  GameVC.swift
//  Hangman
//
//  Created by fsociety.1 on 2/25/18.
//  Copyright © 2018 fsociety.1. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SCLAlertView

extension String {
    func charAt(at: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: at)
        return self[charIndex]
    }
}

struct Words: Decodable {
    let countries_en: [String]
    let animals_en: [String]
    let food_en: [String]
    let sport_en: [String]
}

class GameVC: UIViewController {

    @IBOutlet var keyboardLetters: [UIButton]!
    
    
    @IBOutlet weak var hangImage: UIImageView!
    @IBOutlet weak var wordQM: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var loseLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    var words: [String]!
    var word = " "
    var count = 0
    var questionMark = ""
    var letter = ""
    var winCount = 0
    var loseCount = 0
    var wordsType = ""
    
 
    
    func fillArray(){
        let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] .appendingPathComponent("Words.json")
        let data = try? Data(contentsOf: fileUrl)
        if data != nil{
            do {
                guard let result = data else { return }
                let wordsObject = try JSONDecoder().decode(Words.self, from: result)
                switch wordsType {
                case "Animals":
                    words = wordsObject.animals_en
                case "Food":
                    words = wordsObject.food_en
                case "Sport":
                    words = wordsObject.sport_en
                case "Countries":
                    words = wordsObject.countries_en
                default:
                    break
                }
                let randomIndex = Int(arc4random() % UInt32(words.count))
                word = words[randomIndex]
            } catch {
                print(error)
            }
        }
        else {
            fillArrayFromTxt()
        }
    }
    
    func fillArrayFromTxt() {
        do {
            if let path = Bundle.main.path(forResource: wordsType, ofType: "txt"){
                let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                words = data.components(separatedBy: "\n")
                let randomIndex = Int(arc4random() % UInt32(words.count))
                word = words[randomIndex]
            }
        } catch let err as NSError {
            print(err)
        }
    }
    
    
    
    func makeQuestionMark(){
        for _ in 0..<word.count{
            questionMark = questionMark + "*"
        }
    }
    
    func keyParam(){
        for i in keyboardLetters{
            i.isUserInteractionEnabled = true
            i.layer.cornerRadius = 5
            i.layer.borderWidth = 1
            i.layer.borderColor = UIColor.black.cgColor
            i.tintColor = UIColor.black
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadEverything()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func loadEverything(){
        categoryLabel.text = "\(wordsType):"
        winLabel.text = "Win: \(winCount)"
        loseLabel.text = "Lose: \(loseCount)"
        hangImage.image = nil
        questionMark = ""
        count = 0
        keyParam()
        fillArray()
        makeQuestionMark()
        print(word)
        wordQM.text = questionMark
    }
    
    func showImage() {
        while (count < 10 && questionMark.contains("*")){
            let guess = letter
            hang(guess: guess)
            wordQM.text = questionMark
            break
        }
    }
    
    func hang(guess: String){
        var newQuestionMark = "";
        for i in 0..<word.count {
            let index1 = word.charAt(at: i)
            let index2 = guess.charAt(at: 0)
            let index3 = questionMark.charAt(at: i)
            if (index1 == index2) {
                newQuestionMark += String(index2)
            }
            else if (String(index3) != "*") {
                newQuestionMark += String(index1)
            }
            else {
                newQuestionMark += "*";
            }
        }
        if (questionMark == newQuestionMark) {
            count += 1;
            drawHuman();
        } else {
            questionMark = newQuestionMark;
        }
        if (questionMark == word) {
            hangImage.image = nil
            winCount += 1
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("OK", action: {
                self.loadEverything()
            })
            _ = alert.showSuccess("Congratulations 🎉🎉", subTitle: "On winning the game")
        }
    }
    
    func drawHuman(){
        hangImage.image = UIImage(named: "\(count).png")
        if (count == 10){
            hangImage.image = nil
            loseCount += 1
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("OK", action: {
                self.loadEverything()
            })
            alert.showError("You lose 👎👎", subTitle: "Secret word was: \(word)")
        }
    }
    
    @IBAction func appendLetter(_ sender: UIButton) {
        letter = sender.currentTitle!.lowercased()
        sender.isUserInteractionEnabled = false
        sender.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        sender.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        showImage()
    }
    
    @IBAction func reload(_ sender: Any) {
        loadEverything()
    }
    @IBAction func closeVC(_ sender: Any) {
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoryVC") as UIViewController
        self.present(viewController, animated: false, completion: nil)
    }
    
    
}
