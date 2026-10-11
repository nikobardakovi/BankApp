//
//  EasyBankPage.swift
//  EasyBankUITests
//
//  Created by lmosakhlishvili on 10.02.25.
//

import XCTest

class EasyBankPage {
    private let app: XCUIApplication
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Onboarding

    var onboardingLoginButton: XCUIElement { app.buttons["onboarding.login"] }
    var onboardingRegisterButton: XCUIElement { app.buttons["onboarding.register"] }

    // MARK: - Login

    var loginEmailField: XCUIElement { app.textFields["login.email"] }
    var loginPasswordField: XCUIElement { app.secureTextFields["login.password"] }
    var loginSubmitButton: XCUIElement { app.buttons["login.submit"] }
    var loginErrorText: XCUIElement { app.staticTexts["login.error"] }

    // MARK: - Registration

    var registrationEmailField: XCUIElement { app.textFields["registration.email"] }
    var registrationPasswordField: XCUIElement { app.secureTextFields["registration.password"] }
    var registrationRepeatPasswordField: XCUIElement { app.secureTextFields["registration.repeatPassword"] }
    var registrationSubmitButton: XCUIElement { app.buttons["registration.submit"] }
    var registrationErrorText: XCUIElement { app.staticTexts["registration.error"] }

    // MARK: - Home

    var homeTabButton: XCUIElement { app.tabBars.buttons["Home"] }
    var sendMoneyButton: XCUIElement { app.buttons["home.sendMoney"] }
    var logoutButton: XCUIElement { app.buttons["home.logout"] }

    // MARK: - Logout confirmation

    var logoutAlert: XCUIElement { app.alerts["Logging Out"] }
    var logoutConfirmButton: XCUIElement { logoutAlert.buttons["Yes"] }

    // MARK: - System

    var keyboard: XCUIElement { app.keyboards.firstMatch }
    var keyboardReturnKey: XCUIElement { app.keyboards.buttons["Return"] }

    /// "Use Strong Password?" is an OS prompt; depending on the iOS version it is
    /// shown inside the app's keyboard area or by SpringBoard.
    var strongPasswordDismissButtons: [XCUIElement] {
        [
            app.buttons["Close"],
            app.buttons["Choose My Own Password"],
            springboard.buttons["Close"],
            springboard.buttons["Choose My Own Password"]
        ]
    }
}
