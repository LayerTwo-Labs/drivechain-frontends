import XCTest

@testable import Runner

class RunnerTests: XCTestCase {
  func testBackendHomeStaysOutOfBackups() throws {
    let parent = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: parent) }

    let home = try AppDelegate.prepareBackendHome(in: parent)

    XCTAssertEqual(home.lastPathComponent, "BitWindowHome")
    let values = try home.resourceValues(forKeys: [.isExcludedFromBackupKey, .isDirectoryKey])
    XCTAssertEqual(values.isDirectory, true)
    XCTAssertEqual(values.isExcludedFromBackup, true)
  }

  func testBackendHomeKeepsTheFlagOnASecondStart() throws {
    let parent = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: parent) }

    _ = try AppDelegate.prepareBackendHome(in: parent)
    let home = try AppDelegate.prepareBackendHome(in: parent)

    XCTAssertEqual(try home.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup, true)
  }
}
