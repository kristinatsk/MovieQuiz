//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Kristina Kostenko on 23.09.2025.
//
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func yesButtonClicked() {
        handleAnswer(true)
    }
    
    
    func noButtonClicked() {
        handleAnswer(false)
    }
    
    private func handleAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        viewController?.noButton.isEnabled = isEnabled
        viewController?.yesButton.isEnabled = isEnabled
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func proceedToNextQuestionOrResults() {
        setButtonsEnabled(true)
        if self.isLastQuestion() {
            let resultModel = QuizResultsViewModel(
                title: "Игра закончена",
                text: "Правильных ответов: \(correctAnswers)/10",
                buttonText: "Сыграть еще раз")
                viewController?.show(quiz: resultModel)
            
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            
        }
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        correctAnswers += 1
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + "(\(bestGame.date.dateTimeString)"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [currentGameResultLine, totalPlaysCountLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        
        didAnswer(isCorrectAnswer: isCorrect)
        setButtonsEnabled(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            [weak self] in
            guard let self = self else { return }
            self.setButtonsEnabled(true)
            self.showNextQuestionOrResults()
        }
    }
}
