# ASZFloatingTextField

Implementation of SwiftUI's TextField with floating placeholder and integrated validation.
 
## Installation

Install with Swift Package Manager

```
https://github.com/adamszczuchniak/ASZFloatingTextField
```
    
## Requirements

iOS 16.0+ due to using [LocalizedStringResource](https://developer.apple.com/documentation/foundation/localizedstringresource)

## Example

Check preview in file `ASZFloatingTextField`
```swift
#Preview {
    ASZFloatingViews_Mock()
}
```

## Usage 

### Validation

- **Local valitation:**

    use `.addValidator()` method that requires varadic parameter of type `ASZFieldValidator`. Library has added some common parameters. Check file `ASZFieldValidator` for more details. 

    To check if all field have proper validation use `ASZFloatingForm` this View has closure parameter `validation`, call this closure to invoke `func validate() -> Bool` from ASZFloatingForm. After validations completes closure will return true is all fields are valid or false otherwise.

- **backend validation:**
     
     To show error use binder parameter    `errorMessage: Binding<LocalizedStringResource?>`. Error will be shown when value is not nil

## Author

- Adam Szczuchniak

## License

[MIT](https://github.com/adamszczuchniak/ASZFloatingTextField?tab=MIT-1-ov-file)

