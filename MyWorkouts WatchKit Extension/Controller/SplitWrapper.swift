/*
Abstract:
The wrapper that interfaces with the Split SDK and ensures that a
SplitFactory is instantiated only once per session.
*/

import Foundation
import Split

class SplitWrapper: ObservableObject {

    static let instance: SplitWrapper = {
        return SplitWrapper()
    }()

    private let factory: SplitFactory
    
    @Published var isReady: Bool = false
    @Published var isReadyTimedOut: Bool = false

    @Published private var userConsentValue: Bool?
    
    private let apiKey = "[front-end (client-side) Split API Key goes here]"

    private init() {
        let key = Key(matchingKey: UUID().uuidString)
        
        let config = SplitClientConfig()
        config.logLevel = .verbose
        config.sdkReadyTimeOut = 1000  // Set the time limit (in milliseconds) for Split definitions to be downloaded and enable the .sdkReadyTimedOut event.
        config.userConsent = UserConsent.unknown
        
        userConsentValue = nil
        
        factory = DefaultSplitFactoryBuilder()
            .setApiKey(apiKey)
            .setKey(key)
            .setConfig(config)
            .build()!
        
        factory.client.on(event: .sdkReadyTimedOut) { [weak self] in
            guard let self = self else { return }

            // The .sdkReadyTimedOut event fires when
            // (1) the Split SDK has reached the time limit for downloading the
            //     Split definitions, AND
            // (2) the Split definitions have also not been cached.
            
            DispatchQueue.main.async {
                self.isReadyTimedOut = true
            }
        }
        
        factory.client.on(event: .sdkReady) { [weak self] in
            guard let self = self else { return }
            
            // Set a flag (a @Published var) when the Split definitions are
            // downloaded.
            
            DispatchQueue.main.async {
                self.isReady = true
            }
        }
        
        // Tip: The following events can also be received:
        //    .sdkReadyFromCache - faster than .sdkReady
        //    .sdkUpdated        - when new split definitions are received
    }
    
    public var isUserConsentUnknown: Bool {
        get {
            return UserConsent.unknown == factory.userConsent
        }
    }
    
    public var isUserConsentGranted: Bool {
        get {
            return UserConsent.granted == factory.userConsent
        }
        set {
            factory.setUserConsent(enabled: newValue)
            
            DispatchQueue.main.async {
                self.userConsentValue = newValue
            }
        }
    }

    // MARK: - Split SDK Function Wrappers
    
    /// Retrieves the treatment for the given feature flag (split), as defined in the Split Management
    /// Console.
    /// Parameter: `split`: The name of the split, as defined in the Split Management Console.
    /// Warning: If the Split definitions were not loaded yet, this function will return "CONTROL".
    func eval(_ split: String) -> String {
        return factory.client.getTreatment(split)
    }
    
    /// Sends an event to Split Cloud where it is logged.
    /// Parameter: `event`: The string that will be displayed as the event name.
    /// Important: For the event to be viewable in the Split Management Console, it must be tracked in the
    /// context of a feature flag (split). Split associates the event with the feature flag and displays the
    /// events in the given feature flag's 'Data hub'.
    func track(_ event: String) -> String {
        return
            factory.client.track(trafficType: "user", eventType: event)
                .description
    }
    
    /// Sends the data stored in memory (impressions and events) to Split cloud and clears the successfully
    /// posted data. If a connection issue is experienced, the data will be sent on the next attempt.
    func flush() {
        return factory.client.flush()
    }
    
    deinit {
        destroy()
    }
    
    /// Gracefully shuts down the Split SDK by stopping all background threads, clearing caches, closing
    /// connections, and flushing the remaining unpublished impressions and events.
    private func destroy() {
        return factory.client.destroy()
    }
}

