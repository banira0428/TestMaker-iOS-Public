//
//  EurekaViewController.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/07/21.
//  Copyright © 2018年 YamadaKeita. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Eureka
import ImageRow

class EurekaViewController: FormViewController, GADBannerViewDelegate { //問題の編集、登録画面

    let numOtherInitial = 4

    var testId: String = ""
    var questionId: String = ""
    var selectedImg = UIImage()

    let segment = SegmentedRow<String>("segments")

    override func viewDidLoad() {
        super.viewDidLoad()

        SwitchRow.defaultCellSetup = {
            cell, row in
            cell.height = { 36 }
        }

        ActionSheetRow<String>.defaultCellSetup = {
            cell, row in
            cell.height = { 36 }
        }

        initAd()

        //------------------------------------
        // MARK: - セクション関連処理
        //------------------------------------

        loadGenreSection()

        let sectionWrite = makeSection(tag: "Write")
        let sectionSelect = makeSection(tag: "Select")
        let sectionComplete = makeSection(tag: "Complete")
        let sectionSelectComplete = makeSection(tag: "SelectComplete")

        sectionWrite.hidden = Condition.function(["segments"], { form in
            !((form.rowBy(tag: "segments") as? SegmentedRow)?.value == NSLocalizedString("write", comment: ""))
        })

        sectionSelect.hidden = Condition.function(["segments"], { form in
            !((form.rowBy(tag: "segments") as? SegmentedRow)?.value == NSLocalizedString("select", comment: ""))
        })
        sectionComplete.hidden = Condition.function(["segments"], { form in
            !((form.rowBy(tag: "segments") as? SegmentedRow)?.value == NSLocalizedString("complete", comment: ""))
        })
        sectionSelectComplete.hidden = Condition.function(["segments"], { form in
            !((form.rowBy(tag: "segments") as? SegmentedRow)?.value == NSLocalizedString("select_complete", comment: ""))
        })

        //------------------------------------
        // MARK: - 問題文編集用部品
        //------------------------------------

        let rowProblemWrite = makeTextRow(title: NSLocalizedString("question", comment: ""), hint: NSLocalizedString("required", comment: ""))
        sectionWrite.append(rowProblemWrite)

        let rowProblemSelect = makeTextRow(title: NSLocalizedString("question", comment: ""), hint: NSLocalizedString("required", comment: ""))
        sectionSelect.append(rowProblemSelect)

        let rowProblemComplete = makeTextRow(title: NSLocalizedString("question", comment: ""), hint: NSLocalizedString("required", comment: ""))
        sectionComplete.append(rowProblemComplete)

        let rowProblemSelectComplete = makeTextRow(title: NSLocalizedString("question", comment: ""), hint: NSLocalizedString("required", comment: ""))
        sectionSelectComplete.append(rowProblemSelectComplete)

        //------------------------------------
        // MARK: - 解答編集用部品（選択完答は，選択肢用の部品すべて）
        //------------------------------------

        let rowAnswerWrite = makeTextRow(title: NSLocalizedString("answer", comment: ""), hint: NSLocalizedString("required", comment: ""))
        sectionWrite.append(rowAnswerWrite)

        let rowAnswerSelect = makeTextRow(title: NSLocalizedString("answer", comment: ""), hint: NSLocalizedString("required", comment: ""))
        sectionSelect.append(rowAnswerSelect)

        var rowAnswers: [TextRow] = []
        for _ in 0..<ANSWERMAX {
            rowAnswers.append(makeTextRow(title: NSLocalizedString("answer", comment: ""), hint: NSLocalizedString("required", comment: "")))
        }
        for i in 0..<ANSWERMAX {
            sectionComplete.append(rowAnswers[i])
        }

        var rowValuesSelectComplete: [TextRow] = []
        for i in 0..<SELECTCOMPLETEMAX {

            if i < 2 {
                rowValuesSelectComplete.append(makeTextRow(title: NSLocalizedString("answer", comment: ""), hint: NSLocalizedString("required", comment: "")))

            } else if i < 4 {

                rowValuesSelectComplete.append(makeTextRow(title: NSLocalizedString("other", comment: ""), hint: NSLocalizedString("required", comment: "")))

            } else {

                rowValuesSelectComplete.append(makeTextRow(title: NSLocalizedString("other", comment: ""), hint: NSLocalizedString("required", comment: "")))
                rowValuesSelectComplete[i].hidden = true
                rowValuesSelectComplete[i].evaluateHidden()

            }
        }
        for i in 0..<SELECTCOMPLETEMAX {
            sectionSelectComplete.append(rowValuesSelectComplete[i])
        }

        //------------------------------------
        // MARK: - 外れ選択肢編集用部品
        //------------------------------------

        var rowOthers: [TextRow] = []
        for _ in 0..<OTHERSELECTMAX {
            rowOthers.append(makeTextRow(title: NSLocalizedString("other", comment: ""), hint: NSLocalizedString("required", comment: "")))
        }
        for i in 0..<OTHERSELECTMAX {
            sectionSelect.append(rowOthers[i])
        }
        for i in 0..<OTHERSELECTMAX {

            if i > numOtherInitial - 2 {

                rowOthers[i].hidden = true
                rowOthers[i].evaluateHidden()
                rowOthers[i].reload()
            } else {
                rowOthers[i].hidden = false
                rowOthers[i].evaluateHidden()
            }
        }

        //------------------------------------
        // MARK: - 選択肢数,解答の数,外れの数の編集用部品
        //------------------------------------

        let rowAlertSelect = ActionSheetRow<Int> {
            $0.title = NSLocalizedString("num_select", comment: "")
            $0.selectorTitle = NSLocalizedString("num_select", comment: "")
            $0.options = [2, 3, 4, 5, 6]
            $0.value = numOtherInitial    // initially selected
        }
        rowAlertSelect.onChange {row in

            for i in 0..<OTHERSELECTMAX {

                rowOthers[i].render(showFlg: i <= (row.value ?? 0) - 2)

            }
        }
        sectionSelect.append(rowAlertSelect)

        let rowAlertComplete = ActionSheetRow<Int> {
            $0.title = NSLocalizedString("num_answer", comment: "")
            $0.selectorTitle = NSLocalizedString("num_answer", comment: "")
            $0.options = [2, 3, 4]
            $0.value = 4
        }
        rowAlertComplete.onChange {row in

            for i in 0..<ANSWERMAX {

                rowAnswers[i].render(showFlg: i <= (row.value ?? 0) - 1)

            }
        }
        sectionComplete.append(rowAlertComplete)

        let rowAlertValuesSelectComplete = ActionSheetRow<Int> {
            $0.title = NSLocalizedString("num_select", comment: "")
            $0.selectorTitle = NSLocalizedString("num_select", comment: "")
            $0.options = [3, 4, 5, 6]
            $0.value = 4
        }

        let rowAlertAnswersSelectComplete = ActionSheetRow<Int> {
            $0.title = NSLocalizedString("num_answer", comment: "")
            $0.selectorTitle = NSLocalizedString("num_answer", comment: "")
            $0.options = [2, 3, 4, 5]
            $0.value = 2
        }

        rowAlertAnswersSelectComplete.onChange {row in

            if (rowAlertValuesSelectComplete.value ?? 0) <= (rowAlertAnswersSelectComplete.value ?? 0) {

                rowAlertAnswersSelectComplete.value = (rowAlertValuesSelectComplete.value ?? 0) - 1

                self.showAlertAnswerOver()

                return
            }

            for i in 0..<SELECTCOMPLETEMAX {

                if i < (row.value ?? 0) {
                    rowValuesSelectComplete[i].title = NSLocalizedString("answer", comment: "")
                } else {
                    rowValuesSelectComplete[i].title = NSLocalizedString("other", comment: "")
                }

                rowValuesSelectComplete[i].reload()

            }
        }

        rowAlertValuesSelectComplete.onChange {row in

            if (rowAlertValuesSelectComplete.value ?? 0) <= (rowAlertAnswersSelectComplete.value ?? 0) {

                rowAlertAnswersSelectComplete.value = (rowAlertValuesSelectComplete.value ?? 0) - 1

            }

            for i in 0..<SELECTCOMPLETEMAX {

                if i < row.value ?? 0 {
                    rowValuesSelectComplete[i].hidden = false
                } else {
                    rowValuesSelectComplete[i].hidden = true
                }

                rowValuesSelectComplete[i].evaluateHidden()

            }
        }
        sectionSelectComplete.append(rowAlertAnswersSelectComplete)
        sectionSelectComplete.append(rowAlertValuesSelectComplete)
        
        //------------------------------------
        // MARK: - 解答順序
        //------------------------------------

        
        let rowIsCheckOrder = SwitchRow()
        rowIsCheckOrder.value = false
        rowIsCheckOrder.title = NSLocalizedString("is_check_order", comment: "")
        sectionComplete.append(rowIsCheckOrder)

        //------------------------------------
        // MARK: - 選択肢自動生成の設定用部品
        //------------------------------------

        let rowAuto = SwitchRow()
        rowAuto.value = false
        rowAuto.title = NSLocalizedString("auto", comment: "")
        rowAuto.onChange { [weak self] row in

            changeAuto(auto: row.value ?? false)

        }

        func changeAuto(auto: Bool) {

            for i in 0..<(OTHERSELECTMAX) {

                if auto {
                    rowOthers[i].value = NSLocalizedString("value_auto", comment: "")
                    rowOthers[i].disabled = true
                } else {
                    rowOthers[i].value = ""
                    rowOthers[i].disabled = false
                }

                rowOthers[i].reload()
                rowOthers[i].evaluateDisabled()

            }
        }
        sectionSelect.append(rowAuto)

        //------------------------------------
        // MARK: - 画像取り込み用部品
        //------------------------------------

        let rowImageWrite = makeImageRow(title: NSLocalizedString("image", comment: ""))
        sectionWrite.append(rowImageWrite)

        let rowImageSelect = makeImageRow(title: NSLocalizedString("image", comment: ""))
        sectionSelect.append(rowImageSelect)

        let rowImageComplete = makeImageRow(title: NSLocalizedString("image", comment: ""))
        sectionComplete.append(rowImageComplete)

        let rowImageSelectComplete = makeImageRow(title: NSLocalizedString("image", comment: ""))
        sectionSelectComplete.append(rowImageSelectComplete)

        //------------------------------------
        // MARK: - 解説編集用部品
        //------------------------------------

        let rowExplanationWrite = makeTextRow(title: NSLocalizedString("explanation", comment: ""), hint: NSLocalizedString("any", comment: ""))
        sectionWrite.append(rowExplanationWrite)

        let rowExplanationSelect = makeTextRow(title: NSLocalizedString("explanation", comment: ""), hint: NSLocalizedString("any", comment: ""))
        sectionSelect.append(rowExplanationSelect)

        let rowExplanationComplete = makeTextRow(title: NSLocalizedString("explanation", comment: ""), hint: NSLocalizedString("any", comment: ""))
        sectionComplete.append(rowExplanationComplete)

        let rowExplanationSelectComplete = makeTextRow(title: NSLocalizedString("explanation", comment: ""), hint: NSLocalizedString("any", comment: ""))
        sectionSelectComplete.append(rowExplanationSelectComplete)

        //------------------------------------
        // MARK: - 保存用部品
        //------------------------------------

        let buttonAddWrite = ButtonRow()
        buttonAddWrite.title = NSLocalizedString("save", comment: "")
        buttonAddWrite.onCellSelection { [weak self] _, row in

            guard let localSelf = self else {
                return
            }

            if !isFilledWrite() {
                localSelf.showAlertError()
                return
            }

            let test = localSelf.getTest()
            let q = Question()

            q.problem = rowProblemWrite.value ?? ""
            q.answer = rowAnswerWrite.value ?? ""
            q.type = WRITE
            q.imagePath = localSelf.getFilePath()

            if let explanation = rowExplanationWrite.value {
                q.explanation = explanation
            }

            Model.sharedInstance.addQuestion(question: q, test: test, id: localSelf.questionId)

            localSelf.setRowValue(row: rowProblemWrite, value: "")
            localSelf.setRowValue(row: rowAnswerWrite, value: "")

            localSelf.setRowValue(row: rowExplanationWrite, value: "")

            rowImageWrite.value = UIImage()
            rowImageWrite.reload()
            localSelf.selectedImg = UIImage()

            showAlertEditFinished()

        }

        func isFilledWrite() -> Bool {

            if rowProblemWrite.isEmpty || rowAnswerWrite.isEmpty {
                return false
            }

            return true
        }
        sectionWrite.append(buttonAddWrite)

        let buttonAddSelect = ButtonRow()
        buttonAddSelect.title = NSLocalizedString("save", comment: "")
        buttonAddSelect.onCellSelection { [weak self] _, row in

            guard let localSelf = self else {
                return
            }

            if !isFilledSelection() {
                localSelf.showAlertError()
                return
            }

            let test = localSelf.getTest()
            let q = Question()

            q.problem = rowProblemSelect.value ?? ""
            q.answer = rowAnswerSelect.value ?? ""
            q.type = SELECT
            q.auto = rowAuto.value ?? false
            q.imagePath = localSelf.getFilePath()

            if let explanation = rowExplanationSelect.value {
                q.explanation = explanation
            }

            for i in 0..<(rowAlertSelect.value ?? 0) - 1 {

                let s = Str()
                s.str = rowOthers[i].value ?? ""
                q.others.append(s)

            }

            Model.sharedInstance.addQuestion(question: q, test: test, id: localSelf.questionId)

            localSelf.setRowValue(row: rowProblemSelect, value: "")
            localSelf.setRowValue(row: rowAnswerSelect, value: "")

            for i in 0..<(OTHERSELECTMAX) {

                localSelf.setRowValue(row: rowOthers[i], value: "")

            }

            localSelf.setRowValue(row: rowExplanationSelect, value: "")

            rowImageSelect.value = UIImage()
            rowImageSelect.reload()
            localSelf.selectedImg = UIImage()

            changeAuto(auto: rowAuto.value ?? false)

            showAlertEditFinished()

        }
        func isFilledSelection() -> Bool {

            if rowProblemSelect.isEmpty || rowAnswerSelect.isEmpty {
                return false
            }

            for i in 0..<(rowAlertSelect.value ?? 0) - 1 where rowOthers[i].isEmpty {
                return false
            }

            return true
        }
        sectionSelect.append(buttonAddSelect)

        let buttonAddComplete = ButtonRow()
        buttonAddComplete.title = NSLocalizedString("save", comment: "")
        buttonAddComplete.onCellSelection { [weak self] _, row in

            guard let localSelf = self else {
                return
            }

            if !isFilledComplete() {
                localSelf.showAlertError()
                return
            }

            let test = localSelf.getTest()
            let q = Question()

            q.problem = rowProblemComplete.value ?? ""
            q.type = COMPLETE
            q.imagePath = localSelf.getFilePath()
            q.isCheckOrder = rowIsCheckOrder.value ?? false

            if let explanation = rowExplanationComplete.value {
                q.explanation = explanation
            }

            var answers = [String]()
            for i in 0..<(rowAlertComplete.value ?? 0) {

                let s = Str()
                s.str = rowAnswers[i].value ?? ""
                q.answers.append(s)
                answers.append(s.str)

            }

            if answers.unique.count != answers.count {
                localSelf.showToast(message: NSLocalizedString("msg_duplicated", comment: ""))
                return
            }

            Model.sharedInstance.addQuestion(question: q, test: test, id: localSelf.questionId)

            localSelf.setRowValue(row: rowProblemComplete, value: "")

            for i in 0..<ANSWERMAX {

                localSelf.setRowValue(row: rowAnswers[i], value: "")

            }

            localSelf.setRowValue(row: rowExplanationComplete, value: "")

            rowImageComplete.value = UIImage()
            rowImageComplete.reload()
            localSelf.selectedImg = UIImage()

            showAlertEditFinished()

        }
        func isFilledComplete() -> Bool {

            if rowProblemComplete.isEmpty {
                return false
            }

            for i in 0..<(rowAlertComplete.value ?? 0) where rowAnswers[i].isEmpty {
                return false
            }

            return true
        }
        sectionComplete.append(buttonAddComplete)

        let buttonAddSelectComplete = ButtonRow()
        buttonAddSelectComplete.title = NSLocalizedString("save", comment: "")
        buttonAddSelectComplete.onCellSelection { [weak self] _, row in

            guard let localSelf = self else {
                return
            }

            if !isFilledSelectComplete() {
                localSelf.showAlertError()
                return
            }

            let test = localSelf.getTest()
            let q = Question()

            q.problem = rowProblemSelectComplete.value ?? ""
            q.type = SELECTCOMPLETE
            q.imagePath = localSelf.getFilePath()

            if let explanation = rowExplanationSelectComplete.value {
                q.explanation = explanation
            }

            for i in 0..<(rowAlertValuesSelectComplete.value ?? 0) {

                let s = Str()
                s.str = rowValuesSelectComplete[i].value ?? ""

                if i < (rowAlertAnswersSelectComplete.value ?? 0) {
                    q.answers.append(s)
                } else {
                    q.others.append(s)
                }

            }

            Model.sharedInstance.addQuestion(question: q, test: test, id: localSelf.questionId)

            localSelf.setRowValue(row: rowProblemSelectComplete, value: "")

            for i in 0..<SELECTCOMPLETEMAX {

                localSelf.setRowValue(row: rowValuesSelectComplete[i], value: "")

            }

            localSelf.setRowValue(row: rowExplanationSelectComplete, value: "")

            rowImageSelectComplete.value = UIImage()
            rowImageSelectComplete.reload()
            localSelf.selectedImg = UIImage()

            showAlertEditFinished()

        }
        func isFilledSelectComplete() -> Bool {

            if rowProblemSelectComplete.isEmpty {
                return false
            }

            for i in 0..<(rowAlertValuesSelectComplete.value ?? 0) where rowValuesSelectComplete[i].isEmpty {
                return false
            }

            return true
        }
        sectionSelectComplete.append(buttonAddSelectComplete)

        func showAlertEditFinished() {

            showToast(message: NSLocalizedString("msg_saved", comment: ""))

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                if !self.questionId.isEmpty {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }

        //------------------------------------
        // MARK: - フォームに反映
        //------------------------------------

        form.append(sectionWrite)
        form.append(sectionSelect)
        form.append(sectionComplete)
        form.append(sectionSelectComplete)

        //------------------------------------
        // MARK: - 既存の問題集の編集機能
        //------------------------------------

        if !questionId.isEmpty {

            let questions = getTest().questions

            for i in 0..<questions.count where questions[i].id == questionId {

                switch questions[i].type {
                case WRITE:

                    segment.value = NSLocalizedString("write", comment: "")

                    rowProblemWrite.value = questions[i].problem
                    rowAnswerWrite.value = questions[i].answer
                    rowExplanationWrite.value = questions[i].explanation

                    rowImageWrite.value = UIImage(named: (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "") + questions[i].imagePath.suffix(15))

                    if let image = rowImageWrite.value {

                        selectedImg = image

                    }

                case SELECT:
                    segment.value = NSLocalizedString("select", comment: "")

                    rowProblemSelect.value = questions[i].problem
                    rowAnswerSelect.value = questions[i].answer
                    rowExplanationSelect.value = questions[i].explanation

                    for row in rowOthers {
                        row.hidden = true
                        row.evaluateHidden()
                    }

                    for j in 0..<questions[i].others.count {
                        rowOthers[j].value = questions[i].others[j].str
                        rowOthers[j].hidden = false
                        rowOthers[j].evaluateHidden()
                    }

                    rowAlertSelect.value = questions[i].others.count + 1

                    if questions[i].auto {
                        rowAuto.value = true

                        for row in rowOthers {
                            row.value = NSLocalizedString("value_auto", comment: "")
                            row.disabled = true
                            row.evaluateDisabled()
                        }

                    }

                    rowImageSelect.value = UIImage(named: (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "") + questions[i].imagePath.suffix(15))

                    if let image = rowImageSelect.value {

                        selectedImg = image

                    }

                case COMPLETE:
                    segment.value = NSLocalizedString("complete", comment: "")

                    rowProblemComplete.value = questions[i].problem
                    rowExplanationComplete.value = questions[i].explanation

                    for row in rowAnswers {
                        row.hidden = true
                        row.evaluateHidden()
                    }

                    for j in 0..<questions[i].answers.count {
                        rowAnswers[j].value = questions[i].answers[j].str
                        rowAnswers[j].hidden = false
                        rowAnswers[j].evaluateHidden()
                    }

                    rowAlertComplete.value = questions[i].answers.count

                    rowImageComplete.value = UIImage(named: (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "") + questions[i].imagePath.suffix(15))

                    if let image = rowImageComplete.value {

                        selectedImg = image

                    }
                    
                    rowIsCheckOrder.value = questions[i].isCheckOrder

                case SELECTCOMPLETE:
                    segment.value = NSLocalizedString("select_complete", comment: "")

                    rowProblemSelectComplete.value = questions[i].problem
                    rowExplanationSelectComplete.value = questions[i].explanation

                    for j in 0..<SELECTCOMPLETEMAX {

                        rowValuesSelectComplete[j].hidden = false

                        if j < questions[i].answers.count {
                            rowValuesSelectComplete[j].value = questions[i].answers[j].str
                            rowValuesSelectComplete[j].title = NSLocalizedString("answer", comment: "")
                        } else if j < questions[i].answers.count + questions[i].others.count {
                            rowValuesSelectComplete[j].value = questions[i].others[j - questions[i].answers.count].str
                            rowValuesSelectComplete[j].title = NSLocalizedString("other", comment: "")
                        } else {
                            rowValuesSelectComplete[j].title = NSLocalizedString("other", comment: "")
                            rowValuesSelectComplete[j].hidden = true
                        }

                        rowValuesSelectComplete[j].evaluateHidden()

                    }

                    rowAlertValuesSelectComplete.value = questions[i].answers.count + questions[i].others.count

                    rowAlertAnswersSelectComplete.value = questions[i].answers.count

                    rowImageSelectComplete.value = UIImage(named: (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "") + questions[i].imagePath.suffix(15))

                    if let image = rowImageSelectComplete.value {

                        selectedImg = image

                    }

                default:
                    break
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getTest() -> Test {
        return Model.sharedInstance.getTest(id: testId)
    }

    func setRowValue(row: TextRow, value: String) {
        row.value = value
        row.reload()
    }

    func makeTextRow(title: String, hint: String) -> TextRow {
        let row = TextRow()
        row.title = title
        row.placeholder = hint
        return row
    }

    func makeTextRow(title: String, hint: String, tag: String) -> TextRow {
        let row = TextRow()
        row.title = title
        row.placeholder = hint
        row.tag = tag
        return row
    }

    func makeImageRow(title: String) -> ImageRow {
        let row = ImageRow()
        row.title = title
        row.allowEditor = true
        row.onChange { [weak self] row in

            if let image = row.value {
                self?.selectedImg = image
            } else {
                self?.selectedImg = UIImage()
            }

        }
        return row
    }

    func makeSection(tag: String) -> Section {
        return Section(tag) {
            $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.header?.height = { CGFloat.leastNormalMagnitude }

            $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.footer?.height = { 60 }

        }
    }

    func showAlertError() {

        showToastWithConfirm(message: NSLocalizedString("msg_lack_input", comment: ""))

    }

    func showAlertAnswerOver() {

        showToastWithConfirm(message: NSLocalizedString("msg_answer_excess", comment: ""))

    }

    func getFilePath() -> String {

        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyyMMddHHmmss"
        let date = dateFormater.string(from: Date())

        if let pngImageData = UIImagePNGRepresentation(selectedImg) {

            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(date)
            do {
                try pngImageData.write(to: fileURL)

                return fileURL.path

            } catch {
                return ""
            }

        } else {
            return ""
        }
    }

    func loadGenreSection() {

        let sectionGenre = Section {
            $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.header?.height = { CGFloat.leastNormalMagnitude }
        }

        segment.options = [NSLocalizedString("write", comment: ""), NSLocalizedString("select", comment: ""), NSLocalizedString("complete", comment: ""), NSLocalizedString("select_complete", comment: "")]
        segment.value = NSLocalizedString("write", comment: "")

        sectionGenre.append(segment)

        form.append(sectionGenre)

    }

    func initAd() {

        let ud = UserDefaults.standard
        //購入済みかどうか
        if ud.bool(forKey: "RemoveAd") {

            return
        }

        showAd()

    }

}
