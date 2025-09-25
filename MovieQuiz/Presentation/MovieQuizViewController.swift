import UIKit

final class MovieQuizViewController: UIViewController {


    
    // MARK: - Lifecycle
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        statisticService = StatisticService()
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        
        showLoadingIndicator()
        
        alertPresenter = AlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self)
        
        UserDefaults.standard.set(Date(), forKey: "bestGame.date")
        let date = UserDefaults.standard.object(forKey: "bestGame.date") as? Date ?? Date()
        
        
    }
    
    

    
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    
    func highlightImageBorder(isCorrect: Bool) {
                
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
    }
    
    
    func show(quiz step: QuizStepViewModel) {
        statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
    }
    
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
     
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
        let model = AlertModel(
            title: result.title,
            message: "\(result.text)\n\(message)",
            buttonText: result.buttonText) {
                [weak self] in
                guard let self = self else { return }
                self.presenter.isLastQuestion()
                self.presenter.restartGame()
                
            }
        
        alertPresenter?.show(quiz: model)
        
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let errorModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") {
                [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
                self.presenter.correctAnswers = 0
            }
        
        alertPresenter?.show(quiz: errorModel)
        
    }
    
}

