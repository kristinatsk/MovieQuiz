//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Kristina Kostenko on 26.08.2025.
//

import Foundation
import UIKit

final class AlertPresenter {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
     func show(quiz result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
           
        }
        
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
    
}
