import SwiftUI
import Sentry


@main
struct BikedMilesApp: App {
    init() {
        SentrySDK.start { options in
            options.dsn = "https://86a3afda561178c4d25346af26150727@o33492.ingest.us.sentry.io/4506842707656704"
            options.debug = false
            options.enableTracing = true
            options.attachScreenshot = true // This adds a screenshot to the error events
            options.attachViewHierarchy = true // This adds the view hierarchy to the error events
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
