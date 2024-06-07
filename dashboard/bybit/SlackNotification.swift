//
//  SlackNotification.swift
//  dashboard
//
//  Created by km on 22/01/2024.
//

import Foundation
import SwiftySlack

class SlackNotification {
    private let webAPI = WebAPI(token: "XYZ")
    static let instance = SlackNotification()

    func sendAlert(pair: String, price: String, bestBid: String, bestAsk: String) {
        // Create a block:
        let title = SectionBlock(text: MarkdownText("*Pair level <https://www.bybit.com/trade/usdt/\(pair)|\(pair)> - \(price)*"), accessory: ImageElement(image_url:
            URL(string:
                    Constants.pairSettings[pair]!.imageLink)!,
            alt_text: "calendar thumbnail"))
        let section = SectionBlock(text: MarkdownText("*Bid* \(bestBid) - *Ask* \(bestAsk)"))

        // Create the message:
        let message = Message(blocks: [title, section], to: "#dashboard", alternateText: "A message.")

        webAPI.send(message: message).catch { error in
            print("Cannot send the message: \(error).")
        }
    }
}
