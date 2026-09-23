//
//  EnumConstrant.swift
//  FTTab
//
//  Created by 熊坤鹏 on 2026/9/8.
//

import Foundation

public enum FTTabBarStyle {
    case light
    case dark
}


public enum AppTab: String {
    case chat       // IM
    case video      // 短视频
    case ai         // AI
    case mall       // 商场
    case me         // 我的
    
    
    public var title: String{
        return ""
    }
    
    public var index: Int {
        switch self {
        case .chat:
            return 0  // IM
        case .video:
            return 1  // 短视频
        case .ai:
            return 2  // 商场
        case .mall:
            return 3  // AI
        case .me:
            return 4  // 我的
        }
    }
    
    public static func getTab(index: Int) -> AppTab {
        switch index {
        case 0:
            return .chat
        case 1:
            return .video
        case 2:
            return .ai
        case 3:
            return .mall
        case 4:
            return .me
        default:
            return .chat
        }
    }
}
