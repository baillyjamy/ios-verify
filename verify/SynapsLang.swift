//
//  SynapsLang.swift
//  verify
//
//  Created by Jamy Bailly on 15/10/2023.
//

public enum SynapsLang {
    case English
    case French
    case German
    case Spanish
    case Italian
    case Japanese
    case Korean
    case Portuguese
    case Romanian
    case Russian
    case Turkish
    case Vietnamese
    case Chinese
    case ChineseTraditional

    var code: String {
        switch self {
        case .English:
            return "en"
        case .French:
            return "fr"
        case .German:
            return "de"
        case .Spanish:
            return "es"
        case .Italian:
            return "it"
        case .Japanese:
            return "ja"
        case .Korean:
            return "ko"
        case .Portuguese:
            return "pt"
        case .Romanian:
            return "ro"
        case .Russian:
            return "ru"
        case .Turkish:
            return "tr"
        case .Vietnamese:
            return "vi"
        case .Chinese:
            return "zh-CN"
        case .ChineseTraditional:
            return "zh-TW"
        }
    }
}
