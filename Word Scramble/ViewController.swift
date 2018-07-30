//
//  ViewController.swift
//  Word Scramble
//
//  Created by Артур Азаров on 24.06.2018.
//  Copyright © 2018 Артур Азаров. All rights reserved.
//

import UIKit
import GameplayKit

final class ViewController: UITableViewController {
    
    // MARK: - Properties
    private var allWords = [String]()
    private var usedWords = [String]()
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeWords()
        startGame()
    }
    
    // MARK: - Actions
    
    @IBAction func promptForAnswer(_ sender: Any) {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] _ in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    // MARK: - Methods
    private func initializeWords() {
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt"), let startWords = try? String(contentsOfFile: startWordsPath) {
            allWords = startWords.components(separatedBy: "\n")
        } else {
            allWords = ["silkworm"]
        }
    }
    
    // MARK: -
    
    private func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        title = allWords[0]
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    // MARK: -
    
    private func submit(answer: String) {
        let lowerAnser = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isReal(word: lowerAnser) {
            if isOriginal(word: lowerAnser) {
                if isPossible(word: lowerAnser) {
                    usedWords.insert(lowerAnser, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up, you know!"
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from '\(title!.lowercased())'!"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // MARK: - Helpers
    
    private func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    // NARK: -
    
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    // MARK:
    
    private func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()
        
        for letter in word {
            if let position = tempWord.range(of: String(letter)) {
                tempWord.remove(at: position.lowerBound)
            } else {
                return false
            }
        }
        
        return true
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
}
