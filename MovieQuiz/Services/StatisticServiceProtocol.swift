//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Kristina Kostenko on 31.08.2025.
//

import Foundation
protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
