//
//  VerifyLang.swift
//  verify
//
//  Created by Jamy Bailly on 15/10/2023.
//

public enum VerifyLang {
    case english
    case french
    case german
    case spanish
    case italian
    case japanese
    case korean
    case portuguese
    case romanian
    case russian
    case turkish
    case vietnamese
    case chinese
    case chineseTraditional

    var code: String {
        switch self {
        case .english:
            return "en"
        case .french:
            return "fr"
        case .german:
            return "de"
        case .spanish:
            return "es"
        case .italian:
            return "it"
        case .japanese:
            return "ja"
        case .korean:
            return "ko"
        case .portuguese:
            return "pt"
        case .romanian:
            return "ro"
        case .russian:
            return "ru"
        case .turkish:
            return "tr"
        case .vietnamese:
            return "vi"
        case .chinese:
            return "zh-CN"
        case .chineseTraditional:
            return "zh-TW"
        }
    }
}
