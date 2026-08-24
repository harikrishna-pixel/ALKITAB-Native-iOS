//
//  QuizProtocol.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 18/01/23.
//

import UIKit

let QuizGreen:UIColor = UIColor(red: 78.0 / 255.0, green: 152.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0) //4E982D
let QuizRed:UIColor = UIColor(red: 159.0 / 255.0, green: 34.0 / 255.0, blue: 24.0 / 255.0, alpha: 1.0) // 9F2218

class QuizProtocol: NSObject {
    static var QuizSelectdelegate: QuizSelect?
    static var QuizPaydelegate: QuizPay?
    static var QuizMaindelegate: QuizMainPagePC?
    static var ResultProtocoldelegate: ResultProtocol?
    
    
    static var WalletProtocoldelegate: WalletProtocol?
    static var CardDelegate: CardProtocol?
    
}






protocol CardProtocol {
    func AdNotAvailable()
    func CollectCoin()
}


protocol WalletProtocol {
    func AdNotAvailable()
    func CollectCoin()
}


protocol QuizSelect {
    func Selection(BookCount:String)
    func ChapterSelection(Chapter:String)
}


protocol QuizPay {
    func alertVu()
    func AdAmount(amount:Int)
}

protocol QuizMainPagePC {
    func UpdatePay()
    func nextCall_Action()
    func tryAgain()
    func initQuiz()
    
    func AdNotAvailable()
    func CollectCoin()
}

protocol ResultProtocol {
    func NavigateBack()
    func AdNotAvailable()
}



