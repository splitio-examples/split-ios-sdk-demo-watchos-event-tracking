/*
Abstract:
Supports user consent and transparency by showing the user what tracking and
data would be stored and for what purpose (including how data would be used),
and prompting the user to enable storing data.
*/

import SwiftUI

struct SplitUserConsentView: View {
    @EnvironmentObject var split: SplitWrapper
    
    @State var isUserConsentGranted: Bool
    
    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 10
            ) {
                Text("Do you agree to anonymously send your workout choices, to help us make this app better for you?")
                    .fixedSize(horizontal: false, vertical: true)
                
                Toggle("Send workout choices", isOn: $isUserConsentGranted)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button("OK", role: .cancel) { split.isUserConsentGranted = isUserConsentGranted }
            }
            .padding(10)
        }
    }
}

struct SplitUserConsentView_Previews: PreviewProvider {
    static var previews: some View {
        SplitUserConsentView(isUserConsentGranted: false)
            .environmentObject(SplitWrapper.instance)
    }
}
