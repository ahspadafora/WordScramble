//
//  ContentView.swift
//  WordScramble
//
//  Created by Amber Spadafora on 10/10/20.
//  Copyright © 2020 Amber Spadafora. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var isShowingError = false
    @State private var score = 0
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        isShowingError = true
    }
    
    func startGame() {
        if let fileUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: fileUrl) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkwood"
                usedWords = []
                score = 0
                return
            }
        }
        fatalError()
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        guard isOriginal(word: newWord) else {
            wordError(title: "Word used already", message: "\(newWord) has been used already, fughettaboutit")
            score -= 1
            return
        }
        
        guard isPossible(word: newWord) else {
            wordError(title: "Word isn't possible", message: "That word cannot be made from the original word, what's the matter wit' youus")
            score -= 1
            return
        }
        
        guard isReal(word: newWord) else {
            wordError(title: "Seriously?", message: "That is not a real word ya puts")
            score -= 1
            return
        }
        
        usedWords.insert(newWord, at: 0)
        score += 1
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for char in word {
            if let pos = tempWord.firstIndex(of: char) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        if word.count < 4 || word == rootWord { return false }
        
        let textChecker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = textChecker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    
    var body: some View {
        NavigationView{
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Score: \(score)")
                .navigationBarTitle(Text(rootWord))
                .onAppear(perform: startGame)
                .alert(isPresented: $isShowingError) { () -> Alert in
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
            .navigationBarItems(leading:
                Button(action: {
                    self.startGame()
                }){
                    Text("New Game")
                }
                    
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
