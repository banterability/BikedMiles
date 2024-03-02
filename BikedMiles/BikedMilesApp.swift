import SwiftUI
import Sentry


@main
struct BikedMilesApp: App {
    init() {
        SentrySDK.start { options in
            options.dsn = "https://86a3afda561178c4d25346af26150727@o33492.ingest.us.sentry.io/4506842707656704"
            options.debug = true // Enabled debug when first installing is always helpful
            options.enableTracing = true 

            // Uncomment the following lines to add more data to your events
            // options.attachScreenshot = true // This adds a screenshot to the error events
            // options.attachViewHierarchy = true // This adds the view hierarchy to the error events
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
