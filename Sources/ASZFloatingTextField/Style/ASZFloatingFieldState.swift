import SwiftUI

enum ASZFloatingFieldState {
    case idle
    case focused
    case error
    case disabled

    func backgroundColor(_ style: ASZFloatingFieldStyle) -> Color {
        switch self {
        case .idle:
            style.backgroundColor.idle
        case .focused:
            style.backgroundColor.focused
        case .error:
            style.backgroundColor.error
        case .disabled:
            style.backgroundColor.disabled
        }
    }

    func textColor(_ style: ASZFloatingFieldStyle) -> Color {
        switch self {
        case .idle:
            style.textColor.idle
        case .focused:
            style.textColor.focused
        case .error:
            style.textColor.error
        case .disabled:
            style.textColor.disabled
        }
    }

    func placeholderColor(_ style: ASZFloatingFieldStyle, textEmpty: Bool) -> Color {
        switch self {
        case .idle:
            style.placeholderColor.idle
        case .focused:
            textEmpty ? style.placeholderColor.idle : style.placeholderColor.focused
        case .error:
            style.placeholderColor.error
        case .disabled:
            style.placeholderColor.disabled
        }
    }

    func borderColor(_ style: ASZFloatingFieldStyle) -> Color {
        switch self {
        case .idle:
            style.borderColor.idle
        case .focused:
            style.borderColor.focused
        case .error:
            style.borderColor.error
        case .disabled:
            style.borderColor.disabled
        }
    }

    func descriptionColor(_ style: ASZFloatingFieldStyle) -> Color {
        switch self {
        case .idle:
            style.descriptionColor.idle
        case .focused:
            style.descriptionColor.focused
        case .error:
            style.descriptionColor.error
        case .disabled:
            style.descriptionColor.disabled
        }
    }
}

public enum ASZFloatingSecureFocus {
    case password
    case text
}
