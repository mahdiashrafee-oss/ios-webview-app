import SwiftUI

struct ContentView: View {
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            }
            WebView(url: URL(string: "https://web.mail.us-east-1.awsapps.com/mail/primary/")!)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isLoading = false
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
