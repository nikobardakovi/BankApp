import XCTest

final class BankingFlowTests: BaseClass {
    private lazy var steps = EasyBankSteps(app: app)

    func testLoginWithInvalidEmailFormatShowsError() {
        steps.openLogin()
        steps.logIn(email: "invalid-email", password: "Test#Pass2026")
        steps.assertLoginError(contains: "badly formatted")
    }

    func testLoginWithUnregisteredAccountShowsAuthenticationError() {
        steps.openLogin()
        steps.logIn(email: uniqueEmail(), password: "Test#Pass2026")
        steps.assertLoginError(contains: "malformed or has expired")
    }

    func testRegisterLogOutAndLogInWithNewAccount() {
        let email = uniqueEmail()
        let password = "Test#Pass2026"

        steps.openRegistration()
        steps.register(email: email, password: password)
        steps.assertHomeDisplayed()

        steps.logOut()
        steps.logIn(email: email, password: password)
        steps.assertHomeDisplayed()
    }

    private func uniqueEmail() -> String {
        "easybank.\(UUID().uuidString.prefix(8).lowercased())@example.com"
    }
}
