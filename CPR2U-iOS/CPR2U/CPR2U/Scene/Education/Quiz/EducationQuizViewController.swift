//
//  EducationQuizViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import UIKit
import Combine

final class EducationQuizViewController: UIViewController {
    
    private lazy var questionView = QuizQuestionView(questionNumber: 1, question: "When you find someone who has fallen, you have to compress his chest instantly.")
    
    private lazy var oxChoiceView: OXQuizChoiceView = {
        let view = OXQuizChoiceView(viewModel: viewModel)
        view.alpha = 0
        return view
    }()
    
    private lazy var multiChoiceView: MultiQuizChoiceView = {
        let view = MultiQuizChoiceView(viewModel: viewModel)
        view.alpha = 0
        return view
    }()
    
    private lazy var noticeView = CustomNoticeView(noticeAs: .pf)
    
    private lazy var answerLabel: UILabel =  {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 18)
        label.textColor = .mainBlack
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var answerDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 18)
        label.textColor = .mainBlack
        label.textAlignment = .center
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainLightRed
        button.setTitleColor(.mainBlack, for: .normal)
        button.titleLabel?.font = UIFont(weight: .bold, size: 20)
        button.setTitle("Confirm", for: .normal)
        return button
    }()
    
    private let viewModel = QuizViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    weak var delegate: EducationMainViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpConstraints()
        setUpStyle()
        setUpDelegate()
        Task {
            try await viewModel.receiveQuizList()
            updateQuiz(quiz: viewModel.currentQuiz())
        }
        bind(to: viewModel)
    }
    
    private func setUpConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let make = Constraints.shared
        
        [
            questionView,
            oxChoiceView,
            multiChoiceView,
            submitButton,
            answerLabel,
            answerDescriptionLabel,
            noticeView
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            questionView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: make.space24),
            questionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            questionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            questionView.heightAnchor.constraint(equalToConstant: 148)
            
        ])
        
        [oxChoiceView, multiChoiceView].forEach({ choiceView in
            choiceView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16).isActive = true
            choiceView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16).isActive = true
        })
        
        NSLayoutConstraint.activate([
            oxChoiceView.topAnchor.constraint(equalTo: questionView.bottomAnchor, constant: 78),
            oxChoiceView.heightAnchor.constraint(equalToConstant: 80),
            multiChoiceView.topAnchor.constraint(equalTo: questionView.bottomAnchor, constant: 36),
            multiChoiceView.heightAnchor.constraint(equalToConstant: 280)
        ])
        
        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            submitButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            answerLabel.topAnchor.constraint(equalTo: questionView.bottomAnchor, constant: 200),
            answerLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            answerLabel.widthAnchor.constraint(equalToConstant: 300),
            answerLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            answerDescriptionLabel.topAnchor.constraint(equalTo: answerLabel.bottomAnchor),
            answerDescriptionLabel.centerXAnchor.constraint(equalTo: answerLabel.centerXAnchor),
            answerDescriptionLabel.widthAnchor.constraint(equalToConstant: 300),
            answerDescriptionLabel.heightAnchor.constraint(equalToConstant: 50)
        ])

        NSLayoutConstraint.activate([
            noticeView.topAnchor.constraint(equalTo: view.topAnchor),
            noticeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            noticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .white
        
        navigationController?.navigationBar.topItem?.title = "Quiz"
        let closeItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem = closeItem
    }
    
    private func setUpDelegate() {
        noticeView.delegate = self
    }
}

// MARK: ViewModel Binding
extension EducationQuizViewController {
    private func bind(to viewModel: QuizViewModel) {
        viewModel.selectedAnswerIndex.sink { index in
                if (index != -1) {
                    viewModel.isSelected()
                }
            }
        .store(in: &cancellables)
        
        submitButton.tapPublisher.sink { [weak self] _ in
            self?.nextQuiz()
        }.store(in: &cancellables)
    }
    
    private func nextQuiz() {
        let output = viewModel.transform()
        
        output.isCorrect?.sink { [weak self] isCorrect in
            
            guard let currentQuiz = self?.viewModel.currentQuiz() else { return }
            self?.answerLabel.isHidden = false
            self?.answerDescriptionLabel.isHidden = false
            self?.answerLabel.text = isCorrect ? "Correct!" : "Wrong!"
            self?.answerDescriptionLabel.text = currentQuiz.answerDescription
            self?.submitButton.setTitle("Next", for: .normal)

            guard let answerIndex = self?.viewModel.currentQuiz().answerIndex, let quizType = self?.viewModel.currentQuiz().questionType else {
                return }
            
            switch quizType {
            case .ox:
                self?.oxChoiceView.animateChoiceButton(answerIndex: answerIndex)
                self?.oxChoiceView.interactionEnabled(to: false)
            case .multi:
                self?.multiChoiceView.animateChoiceButton(answerIndex: answerIndex)
                self?.multiChoiceView.interactionEnabled(to: false)
            }
            
        }.store(in: &cancellables)
        
        output.quiz?.sink { quiz in
            self.updateQuiz(quiz: quiz)
            
            switch quiz.questionType {
            case .ox:
                self.oxChoiceView.interactionEnabled(to: true)
            case .multi:
                self.multiChoiceView.interactionEnabled(to: true)
            }
        }.store(in: &cancellables)
        
        output.isQuizEnd.sink { [weak self] isQuizEnd in
            guard let isQuizAllCorrect = self?.viewModel.isQuizAllCorrect() else { return }
            guard let quizResultString = self?.viewModel.quizResultString() else { return }
            
            if isQuizEnd {
                if isQuizAllCorrect {
                    Task {
                        try await self?.viewModel.saveQuizResult()
                        self?.noticeView.setPFResultNotice(isPass: true)
                        self?.noticeView.noticeAppear()
                    }
                } else {
                    self?.noticeView.setPFResultNotice(isPass: false, quizResultString: quizResultString)
                    self?.noticeView.noticeAppear()
                }
            }
        }.store(in: &cancellables)
    }
    
    private func updateQuiz(quiz: Quiz) {
        viewModel.updateSelectedAnswerIndex(index: -1)
        questionView.setUpText(questionNumber: quiz.questionNumber, question: quiz.question)
        
        switch quiz.questionType {
        case .ox:
            updateChoiceView(current: multiChoiceView, as: oxChoiceView)
            oxChoiceView.setUpText()
        case .multi:
            updateChoiceView(current: oxChoiceView, as: multiChoiceView)
            multiChoiceView.setUpText(quiz.answerList)
        }
        
        oxChoiceView.resetChoiceButtonConstraint()
        multiChoiceView.resetChoiceButtonConstraint()
        
        [answerLabel, answerDescriptionLabel].forEach{ $0.isHidden = true }
        answerDescriptionLabel.text = quiz.answerDescription
        submitButton.setTitle("Confirm", for: .normal)
    }
    
    private func updateChoiceView(current: QuizChoiceView, as will: QuizChoiceView) {
        current.alpha = 0.0
        current.isUserInteractionEnabled = false
        will.alpha = 1.0
        will.isUserInteractionEnabled = true
    }
}

// MARK: Objc Function
extension EducationQuizViewController {
    @objc private func closeButtonTapped() {
        let alert = UIAlertController(title: "Quiz Exit", message: "All progress will be lost", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .destructive, handler: { _ in
            self.dismiss(animated: true)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        [confirm, cancel].forEach {
            alert.addAction($0)
        }
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Delegate
extension EducationQuizViewController: CustomNoticeViewDelegate {
    func dismissQuizViewController() {
        delegate?.updateUserEducationStatus()
    }
}
