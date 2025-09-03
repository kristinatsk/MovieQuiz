//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Kristina Kostenko on 01.09.2025.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }
    private var storage: UserDefaults = .standard
    
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            let gameResult = GameResult(correct: correct, total: total,date: date)
            return gameResult
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
            
        }
    }
    
    
    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }
    
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard  totalQuestionsAsked > 0 else { return 0 }
        return (Double(totalCorrectAnswers) / Double(totalQuestionsAsked)) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        totalCorrectAnswers += count
        totalQuestionsAsked += amount
        gamesCount += 1
        let current = GameResult(correct: totalCorrectAnswers, total: totalQuestionsAsked, date: Date())
        
        if current.isBetterThan(bestGame) {
            bestGame = current
        }
        
    }
}


