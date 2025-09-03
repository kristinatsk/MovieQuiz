import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    // MARK: - Lifecycle
    
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var indexLabel: UILabel!
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        statisticService = StatisticService()
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        self.questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter(viewController: self)
        
        UserDefaults.standard.set(Date(), forKey: "bestGame.date")
        let date = UserDefaults.standard.object(forKey: "bestGame.date") as? Date ?? Date()
        
        
    }
    
    //MARK: QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(true)
    }
    
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        handleAnswer(false)
    }
    
    private func handleAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
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
            self.showNextQuestionOrResults()
        }
    }
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizModel = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return quizModel
    }
    
    private func show(quiz step: QuizStepViewModel) {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
    }
    
    
    private func showNextQuestionOrResults() {
        setButtonsEnabled(true)
        if currentQuestionIndex == questionsAmount - 1 {
            let resultModel = QuizResultsViewModel(
                title: "Игра закончена",
                text: "Правильных ответов: \(correctAnswers)/10",
                buttonText: "Сыграть еще раз")
            show(quiz: resultModel)
            
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
            
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let bestGameString: String
        if let bestGame = statisticService?.bestGame {
            bestGameString = "\(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)"
        } else {
            bestGameString = "-"
        }
        
        let message = """
            Количество сыгранных квизов: \((statisticService?.gamesCount ?? 0)/questionsAmount)
            Рекорд: \(bestGameString)
            Средняя точность: \(String(format: "%.2f",statisticService?.totalAccuracy ?? 0))%
            """
        
        let model = AlertModel(
            title: result.title,
            message: "\(result.text)\n\(message)",
            buttonText: result.buttonText) {
                [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(quiz: model)
        
        
    }
    
    
}

