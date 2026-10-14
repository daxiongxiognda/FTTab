//
//  TabConfig.swift
//  FTTab
//
//  Created by 熊坤鹏 on 2026/9/10.
//

import Foundation

/// TabBar 配置中心
/// 负责：
/// 1. 定义 tab 的顺序
/// 2. 根据 tab 和选中态返回对应的图标（区分亮/暗主题）
public class TabConfig: NSObject {

    /// 本地固定顺序：.chat, .video, .ai, .mall, .me
    /// 通过 TabConfig 暴露，外部不需要直接依赖 AppTab
    var orderedTabs: [AppTab] {
        AppTab.defaultConfigOrder
    }

    /// 返回某个 tab 在 TabBar 中的位置索引
    /// - Parameter tab: 目标 tab
    /// - Returns: 位置索引；如果不在配置顺序里，回退到 tab 自身的 index
    func position(for tab: AppTab) -> Int {
        orderedTabs.firstIndex(of: tab) ?? tab.index
    }
    
    
    // MARK: - 主题判定

    /// 判断指定 tab 是否使用黑色主题。
    ///
    /// 优先级：`configItem` → `tabIconItems` 匹配 → 默认白色（false）。
    /// - Parameter tab: 目标 tab。
    /// - Returns: `true` 黑色主题，`false` 白色主题。
    func isBlackTheme(for tab: AppTab) -> Bool {
        // 优先级 1：精确配置项
       
        // 优先级 2：icon 配置项匹配，未命中默认白色
        
        return false
        
    }

    /// 根据 tab 的主题判定，映射为对应的 Bar 样式。
    /// 黑色 → `.dark`，白色 → `.light`。
    /// - Parameter tab: 目标 tab。
    /// - Returns: 对应的 `TTabBarStyle`。
    func preferredBarStyle(for tab: AppTab) -> FTTabBarStyle {
        isBlackTheme(for: tab) ? .dark : .light
    }

    /// 返回 tabBarItem 对应的 image
    /// - Parameters:
    ///   - tab: 目标 tab
    ///   - selectedIndex: 当前选中的索引
    ///   - style: 亮/暗主题
    /// - Returns: 对应状态的图标（alwaysOriginal 渲染模式）
    func tabBarItemImage(tab: AppTab,
                         selectedIndex: Int,
                         style: FTTabBarStyle = .light) -> UIImage? {
        let isSelected = selectedIndex == position(for: tab)
        switch style {
        case .light:
            return lightStyleDefaultImage(tab: tab, isSelected: isSelected)
        case .dark:
            return darkStyleDefaultImage(tab: tab, isSelected: isSelected)
        }
    }

    /// 返回中间加号按钮的图标
    /// - Parameters:
    ///   - style: 亮/暗主题
    ///   - isSelected: 是否选中
    /// - Returns: 加号图标（alwaysOriginal 渲染模式）
    func plusIcon(style: FTTabBarStyle, isSelected: Bool = false) -> UIImage {
        switch style {
        case .light:
            // 未选中：tab_light_plus_icon_unSelected；选中：tab_light_plus_icon_selected
            let image = isSelected
                ? FTTabR.image.tab_LIGHT_PLUS_SELECTED
                : FTTabR.image.tab_LIGHT_PLUS_UN_SELECTED
            return image.withRenderingMode(.alwaysOriginal)
        case .dark:
            // 暗色主题下加号图标不区分选中态，统一使用 tab_DARK_PLUS
            return FTTabR.image.tab_DARK_PLUS.withRenderingMode(.alwaysOriginal)
        }
    }

    // MARK: - Private

    /// 浅色主题下的默认图标
    /// 注意：`.ai` 是加号按钮，复用 plusIcon 的逻辑
    private func lightStyleDefaultImage(tab: AppTab, isSelected: Bool) -> UIImage {
        let image: UIImage
        switch tab {
        case .chat:
            image = isSelected ? FTTabR.image.tab_LIGHT_IM_SELECTED : FTTabR.image.tab_LIGHT_IM_UN_SELECTED
        case .video:
            image = isSelected ? FTTabR.image.tab_LIGHT_VIDEO_SELECTED : FTTabR.image.tab_LIGHT_VIDEO_UN_SELECTED
        case .ai:
            // 加号按钮走独立逻辑
            return plusIcon(style: .light, isSelected: isSelected)
        case .mall:
            image = isSelected ? FTTabR.image.tab_LIGHT_MALL_SELECTED : FTTabR.image.tab_LIGHT_MALL_UN_SELECTED
        case .me:
            image = isSelected ? FTTabR.image.tab_LIGHT_ME_SELECTED : FTTabR.image.tab_LIGHT_ME_UN_SELECTED
        }
        return image.withRenderingMode(.alwaysOriginal)
    }

    /// 深色主题下的默认图标
    /// 注意：`.ai` 是加号按钮，复用 plusIcon 的逻辑
    private func darkStyleDefaultImage(tab: AppTab, isSelected: Bool) -> UIImage {
        let image: UIImage
        switch tab {
        case .chat:
            image = isSelected ? FTTabR.image.tab_DARK_IM_SELECTED : FTTabR.image.tab_DARK_IM_UN_SELECTED
        case .video:
            image = isSelected ? FTTabR.image.tab_DARK_VIDEO_SELECTED : FTTabR.image.tab_DARK_VIDEO_UN_SELECTED
        case .ai:
            return plusIcon(style: .dark, isSelected: isSelected)
        case .mall:
            image = isSelected ? FTTabR.image.tab_DARK_MALL_SELECTED : FTTabR.image.tab_DARK_MALL_UN_SELECTED
        case .me:
            image = isSelected ? FTTabR.image.tab_DARK_ME_SELECTED : FTTabR.image.tab_DARK_ME_UN_SELECTED
        }
        return image.withRenderingMode(.alwaysOriginal)
    }
}

extension AppTab {
    /// TabBar 的默认顺序
    static let defaultConfigOrder: [AppTab] = [.chat, .video, .ai, .mall, .me]
}
