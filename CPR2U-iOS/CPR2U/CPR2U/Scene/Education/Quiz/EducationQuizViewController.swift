//
//  EducationQuizViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import UIKit
import Combine

final class EducationQuizViewController: UIViewController {
    
    private var isPassed: Bool = false
    private lazy var questionView = QuizQuestionView(questionNumber: 1, question: "")
    
    private lazy var oxChoiceView: OXQuizChoiceView = {
        let view = OXQuizChoiceView(viewModel: quizViewModel)
        view.alpha = 0
        return view
    }()
    
    private lazy var multiChoiceView: MultiQuizChoiceView = {
        let view = MultiQuizChoiceView(viewModel: quizViewModel)
        view.alpha = 0
        return view
    }()
    
    private lazy var noticeView = CustomNoticeView(noticeAs: .quizPass)
    
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
        button.setTitle("confirm".localized(), for: .normal)
        return button
    }()
    
    private var eduViewModel: EducationViewModel?
    private let quizViewModel = QuizViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    weak var delegate: EducationMainViewControllerDelegate?
    
    init(eduViewModel: EducationViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.eduViewModel = eduViewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpConstraints()
        setUpStyle()
        setUpAction()
        setUpDelegate()
        
        bind(to: quizViewModel)
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
            multiChoiceView.heightAnchor.constraint(equalToConstant: 286)
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
        
        navigationController?.navigationBar.topItem?.title = "course_quiz".localized()
        let closeItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: nil)
        navigationItem.leftBarButtonItem = closeItem
    }
    
    private func setUpAction() {
        navigationItem.leftBarButtonItem?.tapPublisher.sink { [weak self] in
            self?.closeQuiz()
        }.store(in: &cancellables)
    }
    
    private func setUpDelegate() {
        noticeView.delegate = self
    }
}

extension EducationQuizViewController {
    private func bind(to viewModel: QuizViewModel) {
        
        viewModel.$quiz
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quiz in
                guard let quiz = quiz else { return }
                self?.updateQuiz(quiz: quiz)
            }.store(in: &cancellables)
        
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
        let output = quizViewModel.transform()
        
        output.isCorrect?.sink { [weak self] isCorrect in
            
            guard let currentQuiz = self?.quizViewModel.quiz else { return }
            self?.answerLabel.isHidden = false
            self?.answerDescriptionLabel.isHidden = false
            self?.answerLabel.text = isCorrect ? "Correct!" : "Wrong!"
            self?.answerDescriptionLabel.text = currentQuiz.answerDescription
            self?.submitButton.setTitle("Next", for: .normal)

            guard let answerIndex = self?.quizViewModel.quiz?.answerIndex, let quizType = self?.quizViewModel.quiz?.questionType else {
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
        
        output.isQuizEnd.sink { [weak self] isQuizEnd in
            guard let isQuizAllCorrect = self?.quizViewModel.isQuizAllCorrect() else { return }
            guard let quizResultString = self?.quizViewModel.quizResultString() else { return }
            
            self?.isPassed = isQuizAllCorrect
            
            if isQuizEnd {
                self?.noticeView.setUpQuizResult(isPassed: isQuizAllCorrect, score: quizResultString)
                if isQuizAllCorrect {
                    Task {
                        guard let isSucceed = try await self?.eduViewModel?.saveQuizResult() else { return }
                        if isSucceed {
                            self?.noticeView.noticeAppear()
                        }
                    }
                } else {
                    self?.noticeView.noticeAppear()
                }
            }
        }.store(in: &cancellables)
    }
    
    private func updateQuiz(quiz: Quiz) {
        quizViewModel.updateSelectedAnswerIndex(index: -1)
        questionView.setUpText(questionNumber: quiz.questionNumber, question: quiz.question)
        
        switch quiz.questionType {
        case .ox:
            updateChoiceView(current: multiChoiceView, as: oxChoiceView)
            oxChoiceView.setUpText()
            oxChoiceView.interactionEnabled(to: true)
        case .multi:
            updateChoiceView(current: oxChoiceView, as: multiChoiceView)
            multiChoiceView.setUpText(quiz.answerList)
            multiChoiceView.interactionEnabled(to: true)
        }
        
        oxChoiceView.resetChoiceButtonConstraint()
        multiChoiceView.resetChoiceButtonConstraint()
        
        [answerLabel, answerDescriptionLabel].forEach{ $0.isHidden = true }
        answerDescriptionLabel.text = quiz.answerDescription
        submitButton.setTitle("confirm".localized(), for: .normal)
    }
    
    private func updateChoiceView(current: QuizChoiceView, as will: QuizChoiceView) {
        current.alpha = 0.0
        current.isUserInteractionEnabled = false
        will.alpha = 1.0
        will.isUserInteractionEnabled = true
    }
    
    private func closeQuiz() {
        let alert = UIAlertController(title: "quiz_exit".localized(), message: "quiz_exit_warn_txt".localized(), preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "confirm".localized(), style: .destructive, handler: { _ in
            self.dismiss(animated: true)
        })
        
        let cancel = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        [confirm, cancel].forEach {
            alert.addAction($0)
        }
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Delegate
extension EducationQuizViewController: CustomNoticeViewDelegate {
    func dismissQuizViewController() {
        delegate?.updateUserEducationStatus(isPassed: isPassed)
    }
}
