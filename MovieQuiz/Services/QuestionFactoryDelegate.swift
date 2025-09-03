//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Kristina Kostenko on 21.08.2025.
//
import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
