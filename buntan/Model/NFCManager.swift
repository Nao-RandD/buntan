//
//  NFCManager.swift
//  buntan
//
//  Created by Naoyuki Kan on 2022/04/17.
//

import Foundation
import CoreNFC

/// NFC Readerの状態管理のenum
enum ReaderState {
    case standBy
    case read
    case write
}

class NFCManager: NSObject {
    var session: NFCNDEFReaderSession?
    var message: NFCNDEFMessage?
    var state: ReaderState = .standBy

    var text: String = "myapp://history"

    func startSession(state: ReaderState) {
        self.state = state
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFCはご利用できません")
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "NFCタグをiPhone上部に近づけてください．"
        session?.begin()
    }

    func stopSession(alert: String = "", error: String = "") {
        session?.alertMessage = alert
        if error.isEmpty {
            session?.invalidate()
        } else {
            session?.invalidate(errorMessage: error)
        }
        self.state = .standBy
    }

    func tagRemovalDetect(_ tag: NFCNDEFTag) {
        session?.connect(to: tag) { (error: Error?) in
            if error != nil || !tag.isAvailable {
                self.session?.restartPolling()
                return
            }
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
                self.tagRemovalDetect(tag)
            })
        }
    }

    func updateMessage(_ message: NFCNDEFMessage) -> Bool {
        if message.records.isEmpty { return false }
        var results = [String]()
        for record in message.records {
            if let type = String(data: record.type, encoding: .utf8) {
                if type == "T" { //データ形式がテキストならば
                    let res = record.wellKnownTypeTextPayload()
                    if let text = res.0 {
                        results.append("text: \(text)")
                    }
                } else if type == "U" { //データ形式がURLならば
                    let res = record.wellKnownTypeURIPayload()
                    if let url = res {
                        results.append("url: \(url)")
                    }
                }
            }
        }
        stopSession(alert: "[" + results.joined(separator: ", ") + "]")
        return true
    }
}


// MARK - NFCNDEFReaderSessionDelegate

extension NFCManager: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        //
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // not called
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = "読み込ませるNFCタグは1枚にしてください"
            tagRemovalDetect(tags.first!)
            return
        }
        let tag = tags.first!
        session.connect(to: tag) { (error) in
            if error != nil {
                session.restartPolling()
                return
            }
        }

        tag.queryNDEFStatus { (status, capacity, error) in
            if status == .notSupported {
                self.stopSession(error: "このNFCタグは対応していません")
                return
            }
            if self.state == .write {
                if status == .readOnly {
                    self.stopSession(error: "このNFCタグには書き込みできません")
                    return
                }
                if let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: self.text, locale: Locale(identifier: "en")) {
                    let urlPayload = NFCNDEFPayload.wellKnownTypeURIPayload(string: "myapp://history")!
                    self.message = NFCNDEFMessage(records: [payload, urlPayload])
                    if self.message!.length > capacity {
                        self.stopSession(error: "容量オーバーで書き込めません。\n容量は\(capacity)bytesです")
                        return
                    }
                    tag.writeNDEF(self.message!) { (error) in
                        if error != nil {
                            // self.printTimestamp()
                            self.stopSession(error: error!.localizedDescription)
                        } else {
                            self.stopSession(alert: "書き込み成功しました")
                        }
                    }
                }
            } else if self.state == .read {
                tag.readNDEF { (message, error) in
                    if error != nil || message == nil {
                        self.stopSession(error: error!.localizedDescription)
                        return
                    }
                    if !self.updateMessage(message!) {
                        self.stopSession(error: "このNFCタグは対応していません")
                    }
                }
            }
        }
    }
}
