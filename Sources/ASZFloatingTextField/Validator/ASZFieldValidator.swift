import Foundation
/**
 Override this class to create custom validators
 - Parameter message: Localized message
 - Parameter text: `text: String` parameter from `ASZFloatingTextField`
 */
open class ASZFieldValidator: Equatable {
    public var message: LocalizedStringResource = ""

    public var text: String = ""

    public init(message: LocalizedStringResource) {
        self.message = message
    }

    func validate() -> Bool {
        false
    }

    public static func == (lhs: ASZFieldValidator, rhs: ASZFieldValidator) -> Bool {
        lhs === rhs && lhs.text == rhs.text && lhs.message.key == rhs.message.key
    }
}

// MARK: - PREDEFINED VALIDATORS


/// Cheks if text is empty
public class EmptyFieldValidator: ASZFieldValidator {
    override func validate() -> Bool {
        !text.isEmpty
    }
}

/// Checks if text has only letters
public class NameValidator: ASZFieldValidator {
    private let regex = /^[A-Za-z\\-\\s]+$/

    override func validate() -> Bool {
        text.contains(regex)
    }
}

/// Checks if text has email format
public class EmailValidator: ASZFieldValidator {
    private let regex = /^\w+([\.+-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/

    override func validate() -> Bool {
        text.contains(regex)
    }
}

/// Checks if text has zip code format
public class ZipCodeValidator: ASZFieldValidator {
    private let regex = /^\d{5}(-\d{4})?$/

    override func validate() -> Bool {
        text.contains(regex)
    }
}

/// Checks if text has 8 to 16 characters, at least one letter, one number and one special character
public class PasswordValidator: ASZFieldValidator {
    private let regex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()_+.])[A-Za-z\d!@#$%^&*()_+.]{8,16}$/

    override func validate() -> Bool {
        text.contains(regex)
    }
}

/// Checks if text is equal to `textToMatch` parameter
public class ConfirmPasswordValidator: ASZFieldValidator {
    let textToMatch: String

    public init(textToMatch: String, message: LocalizedStringResource) {
        self.textToMatch = textToMatch
        super.init(message: message)
    }

    override func validate() -> Bool {
        text == textToMatch
    }
}
