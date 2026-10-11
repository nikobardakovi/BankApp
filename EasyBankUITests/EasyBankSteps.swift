//
//  EasyBankSteps.swift
//  EasyBankUITests
//

import XCTest

final class EasyBankSteps {
    private let app: XCUIApplication
    private let page: EasyBankPage
    private let timeout: TimeInterval = 10
    private let maxTypingAttempts = 3

    init(app: XCUIApplication) {
        self.app = app
        self.page = EasyBankPage(app: app)
    }

    // MARK: - Onboarding

    func openLogin() {
        tap(page.onboardingLoginButton)
        assertLoginFormDisplayed()
    }

    func openRegistration() {
        tap(page.onboardingRegisterButton)
        assertRegistrationFormDisplayed()
    }

    // MARK: - Login

    func enterLoginEmail(_ email: String) {
        enterText(email, into: page.loginEmailField)
    }

    func enterLoginPassword(_ password: String) {
        enterPassword(password, into: page.loginPasswordField)
    }

    func submitLogin() {
        tap(page.loginSubmitButton)
    }

    func logIn(email: String, password: String) {
        enterLoginEmail(email)
        enterLoginPassword(password)
        submitLogin()
    }

    func assertLoginFormDisplayed() {
        assertExists(page.loginEmailField, "Login email field")
        assertExists(page.loginPasswordField, "Login password field")
        assertExists(page.loginSubmitButton, "Login submit button")
    }

    func assertLoginError(contains fragment: String) {
        let error = page.loginErrorText
        assertExists(error, "Login error message")
        XCTAssertTrue(
            error.label.contains(fragment),
            "Expected login error to contain '\(fragment)', but it was '\(error.label)'"
        )
        attachScreenshot(named: "Login error")
    }

    // MARK: - Registration

    func enterRegistrationEmail(_ email: String) {
        enterText(email, into: page.registrationEmailField)
    }

    func enterRegistrationPasswords(_ password: String) {
        // Focusing a hidden password field on the registration form makes iOS apply
        // Automatic Strong Password, which covers both fields and discards typed text.
        // Showing both passwords first keeps them as plain text fields.
        showPassword(in: page.registrationPasswordField, using: page.registrationPasswordVisibilityButton)
        showPassword(in: page.registrationRepeatPasswordField, using: page.registrationRepeatPasswordVisibilityButton)

        enterText(password, into: page.registrationPasswordField)
        enterText(password, into: page.registrationRepeatPasswordField)
    }

    func submitRegistration() {
        tap(page.registrationSubmitButton)
    }

    func register(email: String, password: String) {
        enterRegistrationEmail(email)
        enterRegistrationPasswords(password)
        submitRegistration()
    }

    func assertRegistrationFormDisplayed() {
        assertExists(page.registrationEmailField, "Registration email field")
        assertExists(page.registrationPasswordField, "Registration password field")
        assertExists(page.registrationRepeatPasswordField, "Registration repeat password field")
    }

    // MARK: - Home

    func assertHomeDisplayed() {
        let registrationError = page.registrationErrorText.exists ? " Registration error: \(page.registrationErrorText.label)" : ""
        let loginError = page.loginErrorText.exists ? " Login error: \(page.loginErrorText.label)" : ""
        XCTAssertTrue(
            page.sendMoneyButton.waitForExistence(timeout: timeout),
            "Home screen was not displayed.\(registrationError)\(loginError)"
        )
        assertExists(page.homeTabButton, "Home tab")
        attachScreenshot(named: "Home")
    }

    func logOut() {
        tap(page.logoutButton)
        assertExists(page.logoutAlert, "Logout confirmation alert")
        tap(page.logoutConfirmButton)
        assertLoginFormDisplayed()
    }

    // MARK: - Common actions

    private func tap(_ element: XCUIElement) {
        assertExists(element)
        if !element.isHittable {
            dismissKeyboard()
        }
        waitUntilHittable(element)
        element.tap()
    }

    private func enterText(_ text: String, into field: XCUIElement) {
        tap(field)
        for _ in 1...maxTypingAttempts {
            clearText(in: field)
            field.typeText(text)
            if field.value as? String == text {
                return
            }
        }
        XCTFail("Could not enter the expected text into \(field.identifier); value is '\(field.value as? String ?? "")'")
    }

    private func enterPassword(_ password: String, into field: XCUIElement) {
        tap(field)
        for _ in 1...maxTypingAttempts {
            clearText(in: field)
            field.typeText(password)
            if secureTextLength(of: field) == password.count {
                return
            }
        }
        XCTFail("Could not enter the password into \(field.identifier)")
    }

    private func showPassword(in field: XCUIElement, using visibilityButton: XCUIElement) {
        assertExists(field)
        guard field.elementType == .secureTextField else { return }
        tap(visibilityButton)
        let visible = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "elementType == %d", XCUIElement.ElementType.textField.rawValue),
            object: field
        )
        XCTAssertEqual(
            XCTWaiter().wait(for: [visible], timeout: timeout),
            .completed,
            "\(field.identifier) did not become visible"
        )
    }

    private func clearText(in field: XCUIElement) {
        guard let value = field.value as? String, !value.isEmpty, value != field.placeholderValue else { return }
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
    }

    private func secureTextLength(of field: XCUIElement) -> Int {
        (field.value as? String)?.filter { $0 == "•" }.count ?? 0
    }

    private func dismissKeyboard() {
        guard page.keyboard.exists, page.keyboardReturnKey.exists else { return }
        page.keyboardReturnKey.tap()
    }

    // MARK: - Waits

    private func assertExists(_ element: XCUIElement, _ name: String? = nil) {
        XCTAssertTrue(
            element.waitForExistence(timeout: timeout),
            "\(name ?? element.description) did not appear"
        )
    }

    private func waitUntilHittable(_ element: XCUIElement) {
        let hittable = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isHittable == true"), object: element)
        XCTAssertEqual(
            XCTWaiter().wait(for: [hittable], timeout: timeout),
            .completed,
            "\(element.description) is not hittable"
        )
    }

    // MARK: - Reporting

    private func attachScreenshot(named name: String) {
        XCTContext.runActivity(named: name) { activity in
            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.name = name
            screenshot.lifetime = .keepAlways
            activity.add(screenshot)
        }
    }
}
