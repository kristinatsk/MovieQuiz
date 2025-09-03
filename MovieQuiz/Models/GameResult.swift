//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Kristina Kostenko on 31.08.2025.
//
import Foundation
struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    
    func isBetterThan(_ other: GameResult) -> Bool {
        return correct > other.correct
    }
}

