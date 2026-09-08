//
//  MainController.swift
//  Homework1
//
//  Created by Mohammed al-otaibi  
//

import UIKit

class MainController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var noMatchCountLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var multiplierLabel: UILabel!
    
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var guessTextField: UITextField!
    
    var multiplier:Int = 0;
    var noMatchCount:Int = 0;
    var score:Int = 0;
    var guessingPhrase:String = "";
    var genre:String = "";
    var guessedAlreadyRight:[String] = [];
    var allGuesses = Set<String>()
    var phrases:[String] = [];
    let multiplierOptions = [1, 2, 5, 10, 20]
    let numOfTries = 10

    @IBOutlet weak var collectionView: UICollectionView!

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return length of the guessingPhrase
        return guessingPhrase.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
    UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
    UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
    UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let theSize = CGSize(width: 10.0, height: 15.0)
        return theSize
    }
    
    @IBAction func exitButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! CustomCollectionViewCell
        
        let letter = Array(guessingPhrase)[indexPath.row]

        if (guessedAlreadyRight.contains(String(letter))) {
            cell.theImage.image = UIImage(named: "letters/" + String(letter))
            cell.theLabel.text = ""
            // Set the label to be hidden
            cell.theLabel.isHidden = true
        }
        else if !GameRules.isLetter(letter) {
            cell.theImage.image = nil
            cell.theLabel.text = String(letter)
            cell.theLabel.backgroundColor = .clear
            cell.theLabel.isHidden = false
        }
        else{
            cell.theImage.image = nil
            cell.theLabel.text = ""
            // set the label background to light gray
            cell.theLabel.backgroundColor = UIColor.lightGray
            cell.theLabel.isHidden = false
        }
        return cell
    }
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout

        collectionView.dataSource = self
        guard let phraseData = PhraseData.load(from: Bundle.main.url(forResource: "JSONdatafiles", withExtension: nil)) else {
            showUnavailableData()
            return
        }
        phrases = phraseData.list
        genre = phraseData.genre
        reloadGame()
    }

    func showUnavailableData() {
        guessingPhrase = ""
        guessTextField.isEnabled = false
        genreLabel.text = "Phrases unavailable. Please reinstall the app."
        multiplierLabel.text = ""
        noMatchCountLabel.text = ""
        scoreLabel.text = ""
        collectionView.reloadData()
    }

    func reloadGame(){
        guard let phrase = phrases.randomElement() else {
            showUnavailableData()
            return
        }
        noMatchCount = 0
        score = 0
        guessingPhrase = phrase.uppercased()
        guessedAlreadyRight = []
        allGuesses.removeAll()
        guessTextField.isEnabled = true
        redraw()
    }

    @IBAction func check(_ sender: Any) {
        let guess = guessTextField.text ?? ""
        guessTextField.text = ""
        guard !guessingPhrase.isEmpty, noMatchCount < numOfTries,
              !GameRules.isComplete(guessingPhrase, guessed: Set(guessedAlreadyRight)),
              let guessCapitalized = GameRules.acceptGuess(guess, guessed: &allGuesses) else { return }
        do {
            print(guessingPhrase)

            if guessingPhrase.contains(guessCapitalized) {

                let numOfOccurrances = guessingPhrase.filter { $0 == guessCapitalized.first! }.count

                score += multiplier * numOfOccurrances
                guessedAlreadyRight.append(guessCapitalized)

                checkIfGameWon()
            }
            else {
                noMatchCount += 1
                if (noMatchCount == numOfTries){

                    // Game over alert
                    let alert = UIAlertController(title: "You lose", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            self.reloadGame()
                        @unknown default:
                            break
                        }}))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            redraw()

        }
        
    }

    func checkIfGameWon(){
        let gameWon = GameRules.isComplete(guessingPhrase, guessed: Set(guessedAlreadyRight))

        if (gameWon == true) {
            // Game won alert
            let alert = UIAlertController(title: "You Win!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go Again", style: .default, handler: { action in
                switch action.style{
                case .default:
                    self.reloadGame()
                @unknown default:
                    break
                }}))
            self.present(alert, animated: true, completion: nil)

            saveHighScore(score: score)
        }
    }

    func saveHighScore(score:Int){
        // Save the score to file system, if the file does not exist, create it
        let fileManager = FileManager.default
        let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsUrl.appendingPathComponent("highscores.txt")

        // If the file does not exist, create it
        if !fileManager.fileExists(atPath: fileURL.path) {
            fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
        // Read the file
        var fileContents = ""
        do {
            fileContents = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
        }
        catch {
            print("Error reading file")
        }

        // Append the score to the file
        fileContents += "\(score)\n"
        do {
            try fileContents.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            print("Error writing file")
        }
    }

    func redraw() {
        genreLabel.text = "Genre: \(genre)"
        multiplier = multiplierOptions.randomElement()!
        multiplierLabel.text = "Multiplier: " + String(multiplier) + "x"
        noMatchCountLabel.text = "No-match Count: " + String(noMatchCount)
        scoreLabel.text = "Total Score: " + String(score)
        collectionView.reloadData()
    }


}
