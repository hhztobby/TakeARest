import Foundation
import Observation

@Observable
class AppSettings {
    var remindInterval: TimeInterval {
        didSet { UserDefaults.standard.set(remindInterval, forKey: "remindInterval") }
    }
    var repeatInterval: TimeInterval {
        didSet { UserDefaults.standard.set(repeatInterval, forKey: "repeatInterval") }
    }
    var snoozeDelay: TimeInterval {
        didSet { UserDefaults.standard.set(snoozeDelay, forKey: "snoozeDelay") }
    }
    var restThreshold: TimeInterval {
        didSet { UserDefaults.standard.set(restThreshold, forKey: "restThreshold") }
    }
    var customMessages: [String] {
        didSet { UserDefaults.standard.set(customMessages, forKey: "customMessages") }
    }

    init() {
        self.remindInterval = UserDefaults.standard.object(forKey: "remindInterval") as? TimeInterval ?? Constants.defaultRemindInterval
        self.repeatInterval = UserDefaults.standard.object(forKey: "repeatInterval") as? TimeInterval ?? Constants.defaultRepeatInterval
        self.snoozeDelay = UserDefaults.standard.object(forKey: "snoozeDelay") as? TimeInterval ?? Constants.defaultSnoozeDelay
        self.restThreshold = UserDefaults.standard.object(forKey: "restThreshold") as? TimeInterval ?? Constants.defaultRestThreshold
        self.customMessages = UserDefaults.standard.stringArray(forKey: "customMessages") ?? Constants.defaultMessages
    }

    var randomMessage: String {
        customMessages.randomElement() ?? "该休息了！"
    }
}
