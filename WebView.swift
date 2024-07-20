import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = createConfiguration(context: context)
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func createConfiguration(context: Context) -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "newMailHandler")

        let source = """
            document.addEventListener('DOMContentLoaded', function() {
                setInterval(function() {
                    var newMail = document.querySelector('.new-mail'); // Adjust this selector
                    if (newMail) {
                        var summary = newMail.innerText || 'You have a new message.';
                        window.webkit.messageHandlers.newMailHandler.postMessage(summary);
                    }
                }, 5000); // Check every 5 seconds
            });
        """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(script)
        config.userContentController = userContentController
        return config
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "newMailHandler", let messageSummary = message.body as? String {
                DispatchQueue.main.async {
                    self.sendNotificationForNewMail(message: messageSummary)
                }
            }
        }

        private func sendNotificationForNewMail(message: String) {
            let content = UNMutableNotificationContent()
            content.title = "New Mail"
            content.body = message
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
}
