import SwiftUI

public struct ASZFloatingFieldStyle {
    public struct ASZColorState {
        var idle: Color
        var focused: Color
        var error: Color
        var disabled: Color

        public init(idle: Color, focused: Color, error: Color, disabled: Color) {
            self.idle = idle
            self.focused = focused
            self.error = error
            self.disabled = disabled
        }
    }

    var backgroundColor: ASZColorState
    var textColor: ASZColorState
    var placeholderColor: ASZColorState
    var borderColor: ASZColorState
    var descriptionColor: ASZColorState

    var textFont: Font
    var placeholderFont: Font
    var descriptionFont: Font


    public init(backgroundColor: ASZColorState, textColor: ASZColorState, placeholderColor: ASZColorState, borderColor: ASZColorState, descriptionColor: ASZColorState,
                textFont: Font,
                placeholderFont: Font,
                descriptionFont: Font  ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.borderColor = borderColor
        self.descriptionColor = descriptionColor
        self.textFont  = textFont
        self.placeholderFont  = placeholderFont
        self.descriptionFont  = descriptionFont

    }
}

// MARK: - ENVIRONMENT VALUE

public extension EnvironmentValues {
    var aszFloatingFieldStyle: ASZFloatingFieldStyle {
        get {
            self[ASZFloatFieldStyleKey.self]
        }
        set {
            self[ASZFloatFieldStyleKey.self] = newValue
        }
    }
}

// MARK: - ENVIRONMENT KEY

struct ASZFloatFieldStyleKey: EnvironmentKey {

    static var defaultValue = ASZFloatingFieldStyle(
        backgroundColor: .init(idle: .white, focused: .white, error: .white, disabled: .white),
        textColor: .init(idle: .black, focused: .blue, error: .red, disabled: .gray),
        placeholderColor: .init(idle: .gray, focused: .blue, error: .red, disabled: .gray),
        borderColor: .init(idle: .black, focused: .blue, error: .red, disabled: .gray),
        descriptionColor: .init(idle: .black, focused: .black, error: .red, disabled: .gray),
        textFont: .system(size: 16),
        placeholderFont: .system(size: 12),
        descriptionFont: .system(size: 16)
    )
}

