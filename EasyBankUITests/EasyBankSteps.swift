//
//  EasyBankSteps.swift
//  EasyBankUITests
//

import XCTest

final class EasyBankSteps {
    private let app: XCUIApplication
    private let page: EasyBankPage
    private let timeout: TimeInterval = 10
    private let promptTimeout: TimeInterval = 2
    private let maxPasswordAttempts = 3

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
        enterPassword(password, into: page.registrationPasswordField)
        enterPassword(password, into: page.registrationRepeatPasswordField)

        // A strong password suggestion can overwrite the first field while the
        // second one is focused, so check it again before submitting.
        if secureTextLength(of: page.registrationPasswordField) != password.count {
            enterPassword(password, into: page.registrationPasswordField)
        }
        XCTAssertEqual(secureTextLength(of: page.registrationPasswordField), password.count, "Password length mismatch")
        XCTAssertEqual(secureTextLength(of: page.registrationRepeatPasswordField), password.count, "Repeat password length mismatch")
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
        clearText(in: field)
        field.typeText(text)
        XCTAssertEqual((field.value as? String)?.lowercased(), text.lowercased(), "Unexpected text in \(field.identifier)")
    }

    private func enterPassword(_ password: String, into field: XCUIElement) {
        tap(field)
        if dismissStrongPasswordPromptIfShown() {
            tap(field)
        }

        for _ in 1...maxPasswordAttempts {
            clearText(in: field)
            field.typeText(password)
            if secureTextLength(of: field) == password.count {
                return
            }
        }
        XCTFail("Could not enter the password into \(field.identifier)")
    }

    private func clearText(in field: XCUIElement) {
        guard let value = field.value as? String, !value.isEmpty, value != field.placeholderValue else { return }
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
    }

    private func secureTextLength(of field: XCUIElement) -> Int {
        (field.value as? String)?.filter { $0 == "•" }.count ?? 0
    }

    @discardableResult
    private func dismissStrongPasswordPromptIfShown() -> Bool {
        let candidates = page.strongPasswordDismissButtons
        let promptShown = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in candidates.contains { $0.exists } },
            object: nil
        )
        guard XCTWaiter().wait(for: [promptShown], timeout: promptTimeout) == .completed,
              let button = candidates.first(where: { $0.exists && $0.isHittable }) else {
            return false
        }
        button.tap()
        return true
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
