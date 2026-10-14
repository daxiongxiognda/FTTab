//
//  EnumConstant.swift
//  FTTab
//
//  Created by 熊坤鹏 on 2026/10/10.
//

import Foundation

/// TabBar 的样式（明暗主题）。
///
/// 描述 TabBar 在某个 tab 下应采用的视觉风格。
/// 与主题判定 `isBlackTheme(for:)` 的映射关系：
/// - `isBlackTheme == false` → `.light`
/// - `isBlackTheme == true`  → `.dark`
///
/// 映射由 `preferredBarStyle(for:)` 统一处理，避免调用方各自判断。
public enum FTTabBarStyle {
    /// 浅色（白色）主题：浅底 + 深色文字/图标。
    case light

    /// 深色（黑色）主题：深底 + 浅色文字/图标。
    case dark
    
    // case auto  // 跟随系统，未来需要时再加
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

public enum TabClickType {
    case change    // 切换 tab
    case single    // 点击当前 tab（刷新）
    case double    // 快速双击
}

public enum PageConfigDataFrom {
    case cache // 数据来源缓存
    case server // 数据来源服务器
}

public enum TabEvent {
    case click(tab: AppTab, clickType: TabClickType)
    case tabConfigLoaded
    case pageConfigLoaded(from: PageConfigDataFrom, tab: AppTab?)
}
