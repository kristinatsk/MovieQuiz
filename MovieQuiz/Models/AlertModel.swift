//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Kristina Kostenko on 26.08.2025.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    
    let completion: () -> Void
}
