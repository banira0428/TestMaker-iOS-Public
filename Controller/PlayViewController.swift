//
//  PlayView.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2017/01/12.
//  Copyright © 2017年 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import AVFoundation
import GoogleMobileAds
import AlamofireImage

class PlayViewController: UIViewController, GADBannerViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate { //解答画面

    var refine = false
    var testId: String = ""
    var isRetry = false

    var questions = List<Question>()

    @IBOutlet private weak var imageCorrect: UIImageView!
    @IBOutlet private weak var imageMistake: UIImageView!
    @IBOutlet private weak var imageProblem: UIImageView!
    
    var player: AVAudioPlayer!
    
    var number = -1
    
    var numberCalled = 0 //制約更新のため(一度きり)
    
    // swiftlint:disable force_unwrapping
    let correct = Bundle.main.url(forResource: "correct", withExtension: "wav")!
    let mistake = Bundle.main.url(forResource: "mistake", withExtension: "wav")!
    // swiftlint:enable force_unwrapping
    
    @IBOutlet private weak var stackContents: UIStackView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackSelect: UIStackView!
    @IBOutlet private weak var stackWrite: UIStackView!
    @IBOutlet private weak var stackComplete: UIStackView!
    @IBOutlet private weak var stackMistake: UIStackView!
    @IBOutlet private weak var stackManual: UIStackView!
    @IBOutlet private weak var stackSelectComplete: UIStackView!

    @IBOutlet private var ScrollLimitConstraint: NSLayoutConstraint!

    @IBOutlet private var unableScrollConstraint: NSLayoutConstraint!

    @IBOutlet private weak var textProblem: UILabel!
    @IBOutlet private weak var textNumber: UILabel!

    @IBOutlet private weak var buttonConfirm: ButtonCustom!
    @IBOutlet private weak var fieldAnswer: UITextField!

    @IBOutlet private weak var textYourAnswer: UILabel!
    @IBOutlet private weak var textAnswer: UILabel!
    @IBOutlet private weak var textExplanation: UILabel!
    @IBOutlet private weak var buttonNext: UIButton!

    @IBOutlet private var buttonOthers: [ButtonCustom]!
    @IBOutlet private var fieldAnswers: [UITextField]! //タグでソート
    @IBOutlet private var checkBoxes: [CheckBox]!

    var bannerView: GADBannerView!
    var bannerBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        initAd()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        fieldAnswers.forEach { $0.delegate = self }

        buttonOthers.forEach { $0.addTarget(self, action: #selector(buttonEvent(sender:)), for: .touchUpInside) }

        fieldAnswer.delegate = self

        scrollView.canCancelContentTouches = true

        initQuestions()

        loadNext()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if numberCalled > 1 {
            return
        }

        if questions[0].type == SELECT || questions[0].type == SELECTCOMPLETE {

            numberCalled += 1

        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        KeyboardOverlay.newTop = 0
        KeyboardOverlay.currentTop = 0

    }

    //------------------------------------
    // MARK: - 読み込み関連処理
    //------------------------------------

    func initQuestions() {
        let test = Model.sharedInstance.getTest(id: testId)
        let ud = UserDefaults.standard

        if isRetry {
            test.getQuestionsSolved().forEach { self.questions.append($0) }
        } else {
            test.questions.forEach { self.questions.append($0) }
        }

        if ud.bool(forKey: "WrongOnly") {

            let result = List<Question>()

            self.questions.forEach { if !$0.correct { result.append($0) } }

            self.questions = result
        }

        if ud.bool(forKey: "Random") {
            self.questions = shuffleArray(source: self.questions)
        }

        Model.sharedInstance.resetSolved(test: test)
    }

    func loadNext() {

        number += 1

        if number < questions.count {

            let question = questions[number]

            Model.sharedInstance.changeQuestionSolved(question: question, solved: true)

            showLayoutProblem(question: question)

            fieldAnswers.forEach { $0.resignFirstResponder() }

            fieldAnswer.resignFirstResponder()

            switch question.type {

            case WRITE:

                let ud = UserDefaults.standard
                //自己採点モードかどうか
                if ud.bool(forKey: "Self") {

                    buttonConfirm.isHidden = false

                } else {

                    stackWrite.isHidden = false

                    fieldAnswer.becomeFirstResponder()
                }

                self.view.bringSubview(toFront: stackWrite)

            case SELECT:

                stackSelect.isHidden = false

                self.view.bringSubview(toFront: stackSelect)
                var selections = List<String>() //選択肢

                if question.auto {

                    selections = makeChoices(size: question.others.count)

                } else {

                    for s in question.others {
                        selections.append(s.str)
                    }
                }

                selections.append(question.answer)

                selections = shuffleArray(source: selections)

                for i in 0..<buttonOthers.count {

                    if i < question.others.count + 1 {

                        buttonOthers[i].setTitle(selections[i], for: .normal)
                        buttonOthers[i].isHidden = false

                        let textSize = selections[i].getTextSize(font: UIFont.systemFont(ofSize: 17), viewWidth: view.frame.width * 0.8, padding: 8)

                        buttonOthers[i].resizeHeight(height: textSize.height)

                    } else {
                        buttonOthers[i].isHidden = true
                    }
                }

            case COMPLETE:

                stackComplete.isHidden = false

                for i in 0..<fieldAnswers.count {

                    if i < question.answers.count {
                        fieldAnswers[i].isHidden = false
                        fieldAnswers[i].text = ""

                    } else {
                        fieldAnswers[i].isHidden = true
                    }
                }

                fieldAnswers[0].becomeFirstResponder()

                self.view.bringSubview(toFront: stackComplete)

            case SELECTCOMPLETE:
                stackSelectComplete.isHidden = false

                self.view.bringSubview(toFront: stackSelectComplete)

                var selections = List<String>() //選択肢

                question.answers.forEach { selections.append($0.str) }

                question.others.forEach { selections.append($0.str) }

                selections = shuffleArray(source: selections)

                for i in 0..<checkBoxes.count {
                    
                    checkBoxes[i].isChecked = false

                    if i < question.others.count + question.answers.count {
                        checkBoxes[i].setTitle(selections[i], for: .normal)
                        checkBoxes[i].isHidden = false

                        let textSize = selections[i].getTextSize(font: UIFont.systemFont(ofSize: 17), viewWidth: view.frame.width * 0.8, padding: 8)

                        checkBoxes[i].resizeHeight(height: textSize.height)

                    } else {
                        checkBoxes[i].isHidden = true
                    }
                }
            default:
                break

            }

            view.layoutIfNeeded()

            updateViewConstraints()

            if stackContents.frame.height >= self.view.frame.height - 100 {

                unableScrollConstraint.isActive = false
                ScrollLimitConstraint.isActive = true

            } else {

                ScrollLimitConstraint.isActive = false
                unableScrollConstraint.isActive = true
            }

            view.layoutIfNeeded()

            updateViewConstraints()

        } else {

            if let targetViewController = self.storyboard!.instantiateViewController( withIdentifier: "resultView" ) as? ResultViewController {

                targetViewController.testId = self.testId
                targetViewController.questions = self.questions
                refine = false

                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
                KeyboardOverlay.currentTop = 0
                KeyboardOverlay.newTop = 0

                self.navigationController?.pushViewController( targetViewController, animated: true)

            }

        }

    }

    func makeChoices(size: Int) -> List<String> {

        let selections = List<String>() //選択肢

        var answers = [String]()
        for i in 0..<questions.count {
            if questions[i].type == WRITE || questions[i].type == SELECT {
                answers.append(questions[i].answer)
            }
        }

        answers = answers.unique

        var i = 0

        while i < size {

            if !answers.isEmpty {

                let ran = Int.random(in: 0..<answers.count)

                if answers[ran] == questions[number].answer {
                    answers.remove(at: ran)

                } else {
                    selections.append(answers[ran])
                    answers.remove(at: ran)
                    i += 1
                }

            } else {
                selections.append(NSLocalizedString("msg_unable_auto", comment: ""))
                i += 1
            }

        }

        return selections

    }

    func shuffleBang<T>( array: inout List<T>) {
        for index in 0..<array.count {
            let newIndex = Int(arc4random_uniform(UInt32(array.count - index))) + index
            if index != newIndex {
                swap(&array[index], &array[newIndex])
            }
        }
    }

    // 破壊的でないシャッフル / Array(配列)のみ引数で渡せる
    func shuffleArray<S>(source: List<S>) -> List<S> {
        var copy = source
        shuffleBang(array: &copy)
        return copy
    }

    func showLayoutProblem(question: Question) {

        stackWrite.isHidden = true
        stackSelect.isHidden = true
        stackComplete.isHidden = true
        stackSelectComplete.isHidden = true
        buttonConfirm.isHidden = true
        stackMistake.isHidden = true
        stackManual.isHidden = true

        textNumber.text = String(format: NSLocalizedString("number", comment: ""), number + 1)

        textProblem.text = question.getProblem(isReverse: isReverse())

        imageProblem.showImageIfExisting(path: question.imagePath)

    }

    //------------------------------------
    // MARK: - 正誤判定関連処理
    //------------------------------------

    @objc func buttonEvent(sender: UIButton) {

        checkAnswer(answer: sender.currentTitle ?? "")

    }

    @IBAction private func pushOk(_ sender: Any) {

        checkAnswer(answer: fieldAnswer.text ?? "")

    }

    func checkAnswer(answer: String) {

        if answer == questions[number].getAnswer(isReverse: isReverse()) {

            actionCorrect()

        } else {

            actionMistake(yourAnswer: answer)

        }

    }

    @IBAction private func checkAnswerSelectComplete(_ sender: Any) {

        var array = [String]()

        checkBoxes.filter { !$0.isHidden && $0.isChecked }.forEach { array.append($0.currentTitle ?? "") }

        checkAnswer(answers: array)
    }

    @IBAction private func checkAnswerComplete(_ sender: Any) {

        var array = [String]()

        fieldAnswers.filter { !$0.isHidden }.forEach { array.append($0.text ?? "") }

        checkAnswer(answers: array)

    }

    func checkAnswer(answers: Array<String>) {

        var yourAnswer = ""

        answers.filter { !$0.isEmpty }.forEach { yourAnswer.append("\($0) ") }

        var isCorrect = false

        for i in 0..<answers.count {
            isCorrect = false

            for k in 0..<questions[number].answers.count where answers[i] == questions[number].answers[k].str {
                isCorrect = true
            }

            if !isCorrect {
                break //答えとマッチしなかったので不正解
            }
        }

        if isCorrect {
            if answers.count != questions[number].answers.count { //不足があれば不正解（必要条件だけ答えてもダメ）
                isCorrect = false
            }
        }

        if isCorrect {
            if NSOrderedSet(array: answers.filter { _ in true }).array.count != questions[number].answers.count { //同じ答えを複数回使ってもダメ
                isCorrect = false
            }
        }
        
        if isCorrect && questions[number].isCheckOrder {
            for (index, value) in answers.enumerated() {
                if value != questions[number].answers[index].str {
                    isCorrect = false
                    break
                }
            }
        }

        if isCorrect {
            actionCorrect()
        } else {
            actionMistake(yourAnswer: yourAnswer)
        }

    }

    func actionCorrect() {

        let ud = UserDefaults.standard

        fieldAnswer.text = ""

        if ud.bool(forKey: "BGM") {
            do {
                player = try AVAudioPlayer(contentsOf: correct)
                player.play()
            } catch let err as NSError { // エラー処理
                print(err.localizedDescription)
            }
        }

        UIView.animate(withDuration: 0.8) { () -> Void in
            self.imageCorrect.alpha = 1.0
            self.view.bringSubview(toFront: self.imageCorrect)

        }

        if ud.bool(forKey: "Explanation") {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.imageCorrect.alpha = 0.0
            }

            showLayoutManual()
            stackManual.isHidden = true //showLayoutManualより後に
            buttonNext.isHidden = false //showLayoutManualより後にしないとボタンが表示されない

        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.imageCorrect.alpha = 0.0
                self.loadNext()
            }
        }

        for original in Model.sharedInstance.getTest(id: testId).questions where original.id == questions[number].id {
            Model.sharedInstance.correctQuestion(question: original, correct: true)
        }
    }

    func actionMistake(yourAnswer: String) {

        let ud = UserDefaults.standard

        if ud.bool(forKey: "BGM") {
            do {
                player = try AVAudioPlayer(contentsOf: mistake)
                player.play()
            } catch let err as NSError { // エラー処理
                print(err.localizedDescription)
            }

        }

        showLayoutMistake(yourAnswer: yourAnswer)

        for original in Model.sharedInstance.getTest(id: testId).questions where original.id == questions[number].id {
            Model.sharedInstance.correctQuestion(question: original, correct: false)
        }

    }

    func showLayoutMistake(yourAnswer: String) {

        showLayoutManual()

        textYourAnswer.showTextIfExisting(textFormated: String(format: NSLocalizedString("show_your_answer", comment: ""), yourAnswer), text: yourAnswer)

        stackManual.isHidden = true //showLayoutManualより後に
        buttonNext.isHidden = false //showLayoutManualより後にしないとボタンが表示されない

        view.layoutIfNeeded()

        updateViewConstraints()

        if stackContents.frame.height >= self.view.frame.height - 100 {

            unableScrollConstraint.isActive = false
            ScrollLimitConstraint.isActive = true

        } else {

            ScrollLimitConstraint.isActive = false
            unableScrollConstraint.isActive = true
        }

        view.layoutIfNeeded()

        self.view.bringSubview(toFront: stackMistake)

        UIView.animate(withDuration: 0.4) { () -> Void in
            self.imageMistake.alpha = 0.2
            self.view.bringSubview(toFront: self.imageMistake)
        }

    }

    //------------------------------------
    // MARK: - 正誤判定関連処理（自己採点）
    //------------------------------------

    @IBAction private func actionConfirm(_ sender: Any) {
        showLayoutManual()
    }

    @IBAction private func actionCorrectSelf(_ sender: Any) {
        gradeSelf(judge: true)
    }

    @IBAction private func actionIncorrectSelf(_ sender: Any) {
        gradeSelf(judge: false)
    }

    func gradeSelf(judge: Bool) {

        for original in Model.sharedInstance.getTest(id: testId).questions where original.id == questions[number].id {
            Model.sharedInstance.correctQuestion(question: original, correct: judge)
        }

        loadNext()

    }

    func showLayoutManual() {

        stackWrite.isHidden = true
        stackSelect.isHidden = true
        stackComplete.isHidden = true
        stackSelectComplete.isHidden = true
        buttonConfirm.isHidden = true
        stackManual.isHidden = false
        stackMistake.isHidden = false

        textExplanation.showTextIfExisting(textFormated: String(format: NSLocalizedString("show_explanation", comment: ""), questions[number].explanation), text: questions[number].explanation)

        textAnswer.text = String(format: NSLocalizedString("show_answer", comment: ""), questions[number].getAnswer(isReverse: isReverse()))

        textYourAnswer.isHidden = true

        buttonNext.isHidden = true

        self.view.bringSubview(toFront: stackManual)

        view.layoutIfNeeded()

        updateViewConstraints()

        if stackContents.frame.height >= self.view.frame.height - 100 {

            unableScrollConstraint.isActive = false
            ScrollLimitConstraint.isActive = true

        } else {

            ScrollLimitConstraint.isActive = false
            unableScrollConstraint.isActive = true
        }

        view.layoutIfNeeded()

        updateViewConstraints()

    }

    @IBAction private func puchNext(_ sender: Any) {

        imageMistake.alpha = 0.0

        fieldAnswer.text = ""

        loadNext()

    }

    //------------------------------------
    // MARK: - キーボード関連処理
    //------------------------------------

    @objc func keyboardWillChange(notification: NSNotification) {

        let keyboardHeight = self.view.frame.height - (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue.minY
        KeyboardOverlay.newTop = keyboardHeight
        
        
        self.view.removeConstraint(bannerBottomConstraint)
        bannerBottomConstraint.constant = -1 * keyboardHeight
        
        print(keyboardHeight)
        self.view.addConstraint(bannerBottomConstraint)
        self.view.layoutIfNeeded()
        
        self.view.sendSubview(toBack: bannerView)

        KeyboardOverlay.currentTop = keyboardHeight
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 今フォーカスが当たっているテキストボックスからフォーカスを外す
        textField.resignFirstResponder()
        // 次のTag番号を持っているテキストボックスがあれば、フォーカスする
        let nextTag = textField.tag + 1
        if let nextTextField = self.view.viewWithTag(nextTag) {

            if !nextTextField.isHidden {
                nextTextField.becomeFirstResponder()
            }
        }
        return true
    }

    class KeyboardOverlay {
        static var newTop: CGFloat = 0
        static var currentTop: CGFloat = 0
    }

    func initAd() {

        let ud = UserDefaults.standard
        if ud.bool(forKey: "RemoveAd") {

            ScrollLimitConstraint.constant = 10

            return
        }
        
        bannerView = createAd()
        
        self.view.addSubview(bannerView)
        self.view.sendSubview(toBack: bannerView)
        
        bannerBottomConstraint = NSLayoutConstraint(item: bannerView,
                                                    attribute: .bottom,
                                                    relatedBy: .equal,
                                                    toItem: bottomLayoutGuide,
                                                    attribute: .top,
                                                    multiplier: 1,
                                                    constant: 0)
        
        self.view.addConstraints(
            [bannerBottomConstraint,
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
        ])
        
    }

    func isReverse() -> Bool {
        let ud = UserDefaults.standard

        return ud.bool(forKey: "Reverse")
    }

}
