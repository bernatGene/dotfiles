import EventKit
import Foundation

guard CommandLine.arguments.count == 2,
      let year = Int(CommandLine.arguments[1]),
      (1...9998).contains(year),
      CommandLine.arguments[1] == String(format: "%04d", year) else {
    fputs("Usage: obsidian-calendar-events YYYY\n", stderr)
    exit(2)
}

var calendar = Calendar(identifier: .gregorian)
calendar.timeZone = .current
guard let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
      let end = calendar.date(byAdding: .year, value: 1, to: start) else {
    fputs("Unable to calculate date range\n", stderr)
    exit(2)
}

let store = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)
var granted = false

switch EKEventStore.authorizationStatus(for: .event) {
case .fullAccess:
    granted = true
case .notDetermined:
    store.requestFullAccessToEvents { allowed, _ in
        granted = allowed
        semaphore.signal()
    }
    semaphore.wait()
default:
    break
}

guard granted else {
    fputs("Calendar access unavailable; check macOS Calendar permissions\n", stderr)
    exit(1)
}

struct Event: Encodable {
    let title: String
    let start: Int
    let end: Int
    let allDay: Bool
    let calendars: [String]
}

struct EventKey: Hashable {
    let title: String
    let start: Date
    let end: Date
    let allDay: Bool
}

let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
var calendarsByEvent: [EventKey: Set<String>] = [:]
for event in store.events(matching: predicate) {
    let key = EventKey(title: event.title ?? "", start: event.startDate, end: event.endDate, allDay: event.isAllDay)
    calendarsByEvent[key, default: []].insert(event.calendar.title)
}
let events = calendarsByEvent.map { key, calendarNames in
    Event(
        title: key.title,
        start: Int(key.start.timeIntervalSince1970),
        end: Int(key.end.timeIntervalSince1970),
        allDay: key.allDay,
        calendars: calendarNames.sorted()
    )
}
let encoder = JSONEncoder()
do {
    let data = try encoder.encode(events)
    FileHandle.standardOutput.write(data)
    FileHandle.standardOutput.write(Data([0x0a]))
} catch {
    fputs("Unable to encode calendar events\n", stderr)
    exit(1)
}
