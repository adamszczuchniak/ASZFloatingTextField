import SwiftUI

public struct ASZFloatingTextField: View {
    // MARK: - PUBLIC PROPERTIES

    let placeholder: LocalizedStringResource
    let description: LocalizedStringResource?
    @Binding var text: String
    @Binding var errorMessage: LocalizedStringResource?

    // MARK: - PRIVATE PROPERTIES

    private let isSecure: Bool
    @State private var viewState = ASZFloatingFieldState.idle
    @State private var isShowingPassword: Bool = false
    @FocusState private var isFocused: Bool
    @FocusState private var secureFocus: ASZFloatingSecureFocus?
    @Environment(\.aszFloatingFieldStyle) private var style
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.validationInvoker) private var validationInvoker: Bool
    private let validationStorage = ValidationStorage()

    // MARK: - INITIALIZES

    /**
      - Parameter isSecure true will obfuscate text and show toggle icon
     - Parameter placeholder: floating placehoder value
     - Parameter desciption: text displayed under field. Will be replaced with errorMessage if it exists
     - Parameter text: Binder for String value displayed in textField
     - Parameter errorMessage: Binder for error message. Error state with message is shown if this value is not nil. 
     */

    public init(isSecure: Bool = false,
         placeholder: LocalizedStringResource,
         description: LocalizedStringResource? = nil,
         text: Binding<String>,
         errorMessage: Binding<LocalizedStringResource?>)
    {
        self.isSecure = isSecure
        self.placeholder = placeholder
        self.description = description
        _text = text
        _errorMessage = errorMessage
    }

    public var body: some View {
        VStack(spacing: 6) {
            inputView
                .onTapGesture {
                    isFocused = true
                }
                .overlay(alignment: .trailing, content: {
                    eyeButton
                })

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
                .focused($isFocused)
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
        .padding(.trailing, isSecure ? 40 : 0)
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
        if isSecure {
            Group {
                if isShowingPassword {
                    TextField("", text: $text)
                        .focused($secureFocus, equals: .text)
                } else {
                    SecureField("", text: $text)
                        .focused($secureFocus, equals: .password)
                }
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onChange(of: isShowingPassword) { isShowingPassword in
                secureFocus = isShowingPassword ? .text : .password
            }
        } else {
            HStack(spacing: 5) {
                TextField("", text: $text)
            }
        }
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

    @ViewBuilder
    private var eyeButton: some View {
        if isSecure {
            Button(action: {
                isShowingPassword.toggle()
            }, label: {
                Image(systemName: isShowingPassword ? "eye.slash" : "eye")
                    .foregroundStyle(style.borderColor.idle)
                    .padding()
            })
        }
    }

    private func validate() {
        guard !validationStorage.validators.isEmpty else {
            return
        }
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

// MARK: - VALIDATION

public extension ASZFloatingTextField {
    func addValidator(_ validators: ASZFieldValidator...) -> some View {
        validators.forEach { $0.text = text }
        validationStorage.addValidators(validators)
        return preference(key: ValidationPreferenceKey.self, value: validators)
    }
}

// MARK: - PREVIEW MOCK

private struct ASZFloatingViews_Mock: View {
    // Text fields values
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    // Text fields errors
    @State private var emailError: LocalizedStringResource?
    @State private var passwordError: LocalizedStringResource?
    @State private var confirmPasswordError: LocalizedStringResource?

    // View states
    @State private var passDisabled = false
    @State private var showFormAlert = false

    var body: some View {
        VStack(spacing: 20) {
            ASZFloatingForm { isValid in
                ASZFloatingTextField(placeholder: "Email", text: $email, errorMessage: $emailError)
                    .addValidator(EmptyFieldValidator(message: "Field is empty"),
                                  EmailValidator(message: "Email is not valid"))

                ASZFloatingTextField(isSecure: true, placeholder: "Password", text: $password, errorMessage: $passwordError)
                    .addValidator(EmptyFieldValidator(message: "Password is empty"),
                    PasswordValidator(message: "Password must have 8 to 16 characters. At least one letter, one number and one special character."))

                ASZFloatingTextField(isSecure: true, placeholder: "Confirm Password", text: $confirmPassword, errorMessage: $confirmPasswordError)
                    .addValidator(EmptyFieldValidator(message: "Password is empty"),
                        ConfirmPasswordValidator(textToMatch: password, message: "Passwords are different")
                    )


                Button("Check Form") {
                    if isValid() {
                        showFormAlert = true
                    }
                }
            }
            .alert("Form Valid", isPresented: $showFormAlert) {
                        Button("OK", role: .cancel) { }
                    }

        }.padding(.horizontal)
    }
}

#Preview {
    ASZFloatingViews_Mock()
}
