//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Kristina Kostenko on 25.09.2025.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func setButtonsEnabled(_ isEnabled: Bool)
    
}

