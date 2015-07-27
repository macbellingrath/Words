//
//  MasterViewController.swift
//  Anagrams
//
//  Created by Mac Bellingrath on 7/26/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var allWords = [String]()
    var objects = [String]()
    var score = 0
    
   
    @IBOutlet weak var scoreLabel: UILabel!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "0"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "startGame")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "promptForAnswer")

     
    
            do {
                let startWordsPath = NSBundle.mainBundle().pathForResource("start", ofType: "txt")
                let startWords = try NSString(contentsOfFile: startWordsPath!, usedEncoding: nil)
                allWords = startWords.componentsSeparatedByString("\n") as [String]
                } catch let error {
                    allWords = ["silkworm"]
                    print(error)
                }
        startGame()
    }

        
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: - Segues

    
    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }

    //MARK: - Helper Methods
    func startGame() {
        allWords.shuffle()
        title = allWords[0]
        objects.removeAll(keepCapacity: true)
        tableView.reloadData()
        
    }
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .Alert)
       
        ac.addTextFieldWithConfigurationHandler(nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self, ac] _ in
            let answer = ac.textFields![0] as UITextField
            self.submitAnswer(answer.text!)
        }
        ac.addAction(submitAction)
        presentViewController(ac, animated: true, completion: nil)
        
    }
    
    
    func submitAnswer(answer: String) {
        let lowerAnswer = answer.lowercaseString
        if wordIsPossible(lowerAnswer) {
            if wordIsOriginal(lowerAnswer) {
                if wordIsReal(lowerAnswer) {
                    if wordNotBlank(lowerAnswer){
                    objects.insert(answer, atIndex: 0)
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                        score += 1
                        scoreLabel.text = "\(score)"
                    } else {
                        showErrorMessage("You must enter a word", title: "Guess was empty")
                    }
                } else {
                    showErrorMessage("You can't just make words up, you know!", title: "Word not recognized")
            }
                
        } else {
            showErrorMessage("That word has already been used!", title: "Try again!")
        }
    } else {
        showErrorMessage("You cannot spell that word from '\(title!.lowercaseString)'!", title: "Word not possible")
    }
    }
    
    // MARK: - Word Checking
    func wordIsPossible(word:String) -> Bool {
        var tempWord = title?.lowercaseString
        for letter in word.characters{
            if let pos = tempWord?.rangeOfString(String(letter)) {
                if pos.isEmpty {
                    return false
                } else {
                    tempWord?.removeAtIndex(pos.startIndex)
                }
            } else {
                return false
            }
        }

        return true
    }
    
    
    func wordIsOriginal(word: String) -> Bool {
        let myWord:Bool = word != title
        return !(objects.contains(word)) && myWord
       
    }
    
    
    func wordIsReal(word: NSString) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.length)
        let misspelledRange = checker.rangeOfMisspelledWordInString(word as String, range: range, startingAt: 0, wrap: false, language: "en")
        
                return misspelledRange.location == NSNotFound
    }
    
    func wordNotBlank(word: String) -> Bool {
        return word != ""
    }
    
    
    
    func showErrorMessage(errorMessage: String, title: String){
        
    let ac = UIAlertController(title: title, message: errorMessage, preferredStyle: .Alert)
    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    presentViewController(ac, animated: true, completion: nil)
    }
    
    
}

