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

    static func from(code: String) -> VerifyLang {
        switch code {
        case "en":
            return .english
        case "fr":
            return .french
        case "de":
            return .german
        case "es":
            return .spanish
        case "it":
            return .italian
        case "ja":
            return .japanese
        case "ko":
            return .korean
        case "pt":
            return .portuguese
        case "ro":
            return .romanian
        case "ru":
            return .russian
        case "tr":
            return .turkish
        case "vi":
            return .vietnamese
        case "zh-CN":
            return .chinese
        case "zh-TW":
            return .chineseTraditional
        default:
            return .english
        }
    }
}
