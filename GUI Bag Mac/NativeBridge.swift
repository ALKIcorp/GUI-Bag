import Foundation
import WebKit

final class NativeBridge: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    private let store: ItemStore
    weak var webView: WKWebView?

    init(store: ItemStore) {
        self.store = store
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            message.name == "guiBagBridge",
            let body = message.body as? [String: Any],
            let requestId = body["requestId"] as? Int,
            let action = body["action"] as? String
        else {
            return
        }

        do {
            let payload = body["payload"]
            let response: [String: Any]

            switch action {
            case "listItems":
                response = try store.listItemsResponse()
            case "createItem":
                let createPayload: CreateItemPayload = try decode(payload)
                response = try store.createItem(payload: createPayload)
            case "updateItem":
                let updatePayload: UpdateItemPayload = try decode(payload)
                response = try store.updateItem(payload: updatePayload)
            case "deleteItem":
                let deletePayload: DeleteItemPayload = try decode(payload)
                response = try store.deleteItem(payload: deletePayload)
            default:
                throw ItemStoreError.invalidPayload
            }

            sendResponse(requestId: requestId, ok: true, payload: response)
        } catch {
            sendResponse(
                requestId: requestId,
                ok: false,
                payload: [:],
                error: ["message": error.localizedDescription]
            )
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        NSLog("Navigation failed: %@", error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        NSLog("Provisional navigation failed: %@", error.localizedDescription)
    }

    private func decode<T: Decodable>(_ payload: Any?) throws -> T {
        let object = payload ?? [:]
        let data = try JSONSerialization.data(withJSONObject: object)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func sendResponse(requestId: Int, ok: Bool, payload: [String: Any], error: [String: Any]? = nil) {
        guard let webView else { return }

        var response: [String: Any] = [
            "requestId": requestId,
            "ok": ok,
            "payload": payload
        ]
        if let error {
            response["error"] = error
        }

        guard
            let data = try? JSONSerialization.data(withJSONObject: response)
        else {
            return
        }

        let encoded = data.base64EncodedString()
        let script = "window.__guiBagNativeReceive && window.__guiBagNativeReceive('\(encoded)');"
        webView.evaluateJavaScript(script)
    }
}
