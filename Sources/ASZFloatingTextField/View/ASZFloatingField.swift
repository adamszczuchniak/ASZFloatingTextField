import SwiftUI

/// Readonly implementation of `ASZFloatingTextField`
struct ASZFloatingField: View {
    // MARK: - PUBLIC PROPERTIES

    let placeholder: LocalizedStringResource
    let description: LocalizedStringResource?
    @Binding var text: String
    @Binding var errorMessage: LocalizedStringResource?
    @Binding var isFocused: Bool

    let action: () -> Void

    // MARK: - PRIVATE PROPERTIES

    @State private var viewState = ASZFloatingFieldState.idle
    @Environment(\.aszFloatingFieldStyle) private var style
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.validationInvoker) private var validationInvoker
    private let validationStorage = ValidationStorage()

    // MARK: - INITIALIZES

    public init(placeholder: LocalizedStringResource,
         description: LocalizedStringResource? = nil,
         text: Binding<String>,
         errorMessage: Binding<LocalizedStringResource?>,
         isFocused: Binding<Bool>,
         action: @escaping () -> Void)
    {
        self.placeholder = placeholder
        self.description = description
        _text = text
        _errorMessage = errorMessage
        _isFocused = isFocused
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 6) {
            inputView
                .onTapGesture {
                    isFocused = true
                    action()
                }

            descriptionView
        }
        .onChange(of: errorMessage) { errorMessage in
            if errorMessage == nil {
                viewState = isFocused ? .focused : .idle
            } else {
                viewState = .error
            }
        }
        .onChange(of: validationInvoker) { invoker in
            if invoker {
                validate()
            }
        }
        .onChange(of: isEnabled) { isEnabled in
            viewState = isEnabled ? .idle : .disabled
        }
        .onAppear {
            viewState = isEnabled ? .idle : .disabled
        }
    }

    private var inputView: some View {
        ZStack(alignment: .leading) {
            Text(placeholder)
                .foregroundStyle(viewState.placeholderColor(style, textEmpty: text.isEmpty))
                .font(text.isEmpty ? style.textFont : style.placeholderFont)
                .offset(x: 0,
                        y: text.isEmpty ? 0 : -10)
                .animation(.easeIn(duration: 0.15), value: text.isEmpty)

            fieldView
                .foregroundStyle(viewState.textColor(style))
                .font(style.textFont)
                .offset(x: 0,
                        y: text.isEmpty ? 0 : 10)
                .animation(.easeIn(duration: 0.15), value: text.isEmpty)
                .onChange(of: isFocused) { isFocused in
                    if isFocused {
                        viewState = .focused
                    } else if viewState != .error {
                        viewState = .idle
                    }
                    if !isFocused {
                        validate()
                    }
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(viewState.backgroundColor(style))
        }
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(viewState.borderColor(style), lineWidth: 1.5)
        }
    }

    @ViewBuilder
    private var fieldView: some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let text = errorMessage ?? description {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(style.descriptionFont)
                .foregroundStyle(viewState.descriptionColor(style))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func validate() {
        let (isValid, message) = validationStorage.validate()
        if isValid {
            errorMessage = nil
            viewState = isFocused ? .focused : .idle
        } else {
            errorMessage = message
            viewState = .error
        }
    }
}

extension ASZFloatingField {
    func addValidator(_ validators: ASZFieldValidator...) -> some View {
        validators.forEach { $0.text = text }
        validationStorage.addValidators(validators)
        return preference(key: ValidationPreferenceKey.self, value: validators)
    }
}
