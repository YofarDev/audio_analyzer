import Cocoa
import FlutterMacOS
import XCTest


@testable import audio_analyzer

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

  func testClearCacheReturnsNil() {
    let plugin = AudioAnalyzerPlugin()

    let call = FlutterMethodCall(methodName: "clearCache", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertNil(result)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

}
