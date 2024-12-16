import SwiftUI

/// Typealias for () -> Bool
public typealias ValidateClosure = () -> Bool

public struct ASZFloatingForm<Content: View>: View {
    @ViewBuilder let content: (@escaping ValidateClosure) -> Content

    @State private var validators: [ASZFieldValidator] = []
    @State private var validationInvoker = false

    public init(@ViewBuilder content: @escaping (@escaping ValidateClosure) -> Content) {
        self.content = content
    }

    public var body: some View {
        Group {
            content(validate)
        }
        .onPreferenceChange(ValidationPreferenceKey.self, perform: { validators in
            self.validators = validators
        })
        .environment(\.validationInvoker, validationInvoker)
        .onChange(of: validationInvoker) { invoker in
            if invoker {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    validationInvoker = false
                }
            }
        }
    }

    private func validate() -> Bool {
        validationInvoker = true
        for validator in validators {
            if !validator.validate() {
                return false
            }
        }
        return true
    }
}

// MARK: - PREFERENCE KEY

struct ValidationPreferenceKey: PreferenceKey {
    static var defaultValue: [ASZFieldValidator] = []

    static func reduce(value: inout [ASZFieldValidator], nextValue: () -> [ASZFieldValidator]) {
        value += nextValue()
    }
}

// MARK: - ENVIRONMENT KEY

private struct ValidationInvokerKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    /// View using this environment value must be wrapped in `ASZFloatingForm`
    var validationInvoker: Bool {
        get { self[ValidationInvokerKey.self] }
        set { self[ValidationInvokerKey.self] = newValue }
    }
}
