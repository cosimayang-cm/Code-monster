//
//  Monster5APIError.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import Foundation

/// API 錯誤回應模型
struct Monster5APIError: Codable, Equatable, Error, Sendable {
    let message: String
}
