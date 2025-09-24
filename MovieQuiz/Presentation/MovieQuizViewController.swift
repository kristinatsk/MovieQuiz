import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    
    
    // MARK: - Lifecycle
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    private let presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        statisticService = StatisticService()
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        
        alertPresenter = AlertPresenter(viewController: self)
        presenter.viewController = self
        
        UserDefaults.standard.set(Date(), forKey: "bestGame.date")
        let date = UserDefaults.standard.object(forKey: "bestGame.date") as? Date ?? Date()
        
        
    }
    
    //MARK: QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }

    
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func showAnswerResult(isCorrect: Bool) {
        
        if isCorrect {
            correctAnswers += 1
        }
        
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        setButtonsEnabled(false)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            [weak self] in
            guard let self = self else { return }
            self.setButtonsEnabled(true)
            self.previewImage.layer.borderWidth = 0
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    
   
    
    func show(quiz step: QuizStepViewModel) {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
    }
    
    
    private func showNextQuestionOrResults() {
        setButtonsEnabled(true)
        if presenter.isLastQuestion() {
            let resultModel = QuizResultsViewModel(
                title: "Игра закончена",
                text: "Правильных ответов: \(correctAnswers)/10",
                buttonText: "Сыграть еще раз")
            show(quiz: resultModel)
            
        } else {
            presenter.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
            
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let bestGameString: String
        if let bestGame = statisticService?.bestGame {
            bestGameString = "\(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)"
        } else {
            bestGameString = "-"
        }
        
        let message = """
            Количество сыгранных квизов: \((statisticService?.gamesCount ?? 0)/presenter.questionsAmount)
            Рекорд: \(bestGameString)
            Средняя точность: \(String(format: "%.2f",statisticService?.totalAccuracy ?? 0))%
            """
        
        let model = AlertModel(
            title: result.title,
            message: "\(result.text)\n\(message)",
            buttonText: result.buttonText) {
                [weak self] in
                guard let self = self else { return }
                self.presenter.isLastQuestion()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(quiz: model)
        
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let errorModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") {
                [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(quiz: errorModel)
        
    }
    
}

