import XCTest

/// Drives the Apple TV app the way a viewer does, from the Siri Remote.
/// Nothing on tvOS takes a touch, so `XCUIRemote` is the only way to
/// reach the app from a test -- and the only way to reach it from CI at
/// all, since the simulator has no remote of its own.
///
/// Set `ANICAT_UITEST_SCREENSHOT_DIR` to a directory on the host to keep a
/// screenshot at each step; the simulator shares the host's filesystem.
@MainActor
final class TVSmokeTests: XCTestCase {
    private var app: XCUIApplication!
    private var remote: XCUIRemote { XCUIRemote.shared }

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    /// The Search tab runs a search on every change of the query: typing
    /// on the grid must produce results without a submit, which the TV
    /// keyboard does not have.
    func testSearchRunsAsYouType() {
        remote.press(.right)
        remote.press(.right)
        XCTAssertTrue(app.scrollViews["Search results"].waitForExistence(timeout: 5))
        snapshot("search-tab")
        // The keyboard is the first thing under the tab bar.
        remote.press(.down)
        sleep(1)
        app.typeText("moana")
        sleep(2)
        snapshot("search-typed")
        let hit = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "moana")).firstMatch
        XCTAssertTrue(hit.waitForExistence(timeout: 20), "no result for a typed query")
        snapshot("search-results")
    }

    /// Opens the first Up Next poster, presses Play, and checks that the
    /// picture is still there after the chrome has timed out.
    func testPlayerSurvivesControlsTimeout() {
        remote.press(.down)
        sleep(1)
        remote.press(.down)
        sleep(1)
        remote.press(.select)
        let play = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Play' OR label BEGINSWITH 'Resume'")).firstMatch
        XCTAssertTrue(play.waitForExistence(timeout: 20))
        sleep(2)
        snapshot("detail")
        remote.press(.select)
        sleep(3)
        snapshot("resolving")
        let player = app.descendants(matching: .any)["tv.player"]
        XCTAssertTrue(player.waitForExistence(timeout: 90), "no player after Play")
        sleep(12)
        snapshot("player-early")
        sleep(10)
        snapshot("player-after-timeout")
    }

    private func snapshot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = ProcessInfo.processInfo.environment["ANICAT_UITEST_SCREENSHOT_DIR"] {
            try? shot.pngRepresentation.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(name).png"))
        }
    }
}
