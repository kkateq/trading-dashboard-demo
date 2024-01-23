//
//  SlackNotification.swift
//  dashboard
//
//  Created by km on 22/01/2024.
//

import Foundation
import SwiftySlack

class SlackNotification {
    private let webAPI = WebAPI(token: "xoxb-876704705971-6531916734240-vCRxpjELgeFaxm5sqddC2yhD")
    static let instance = SlackNotification()

    func sendAlert(pair: String, price: String, bestBid: String, bestAsk: String) {
        // Create a block:
        let title = SectionBlock(text: MarkdownText("*Pair level \(pair) - \(price)*"))
        let section = SectionBlock(text: MarkdownText("*Bid* \(bestBid) - *Ask* \(bestAsk)"))
      
        // Create the message:
        let message = Message(blocks: [title, section], to: "#dashboard", alternateText: "A message.")

        webAPI.send(message: message).catch { error in
            print("Cannot send the message: \(error).")
        }
    }
}
