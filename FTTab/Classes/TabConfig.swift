//
//  TabConfig.swift
//  FTTab
//
//  Created by 熊坤鹏 on 2026/9/10.
//

import Foundation

struct TabIconConfigItem {
    var name: String?
    var sort: Int64?
    /// 首次应用远程配置时是否默认选中；不参与排序。
    var homePage: Bool?
    var normalImage: UIImage?
    var seletedImage: UIImage?
    var darkNormalImage: UIImage?
    var darkSelectedImage: UIImage?
    var normalPagFile: String?
    var seletedPagFile: String?
    var selectPlaceholderImage: UIImage?
    var notSelectPlaceholderImage: UIImage?
    var move: Bool?
    var jumpURL: String?
    var isBlackTheme: Bool?
}

public class TabConfig: NSObject {
    public override init() {
        super.init()
    }
}
extension TabConfig {
    
    /// 本地固定顺序：    .chat, .video, .ai, .mall, .me
    var orderedTabs: [AppTab] {
        AppTab.defaultConfigOrder
    }
    func position(for tab: AppTab) -> Int {
        orderedTabs.firstIndex(of: tab) ?? tab.index
    }
    
    // 返回tabBarItem对应的image
    func tabBarItemImage(tab: AppTab, selectedIndex: Int, style: FTTabBarStyle = .light) -> UIImage? {
        var resImage: UIImage
        let isSelected = selectedIndex == position(for: tab)
        switch style {
        case .light:
            resImage = lightStyleDefaultImage(tab: tab, isSelected: isSelected)
        case .dark:
            resImage = darkStyleDefaultImage(tab: tab, isSelected: isSelected)
        }
        
        return resImage
    }
    func plusIcon(style: FTTabBarStyle, isSelected: Bool = false) -> UIImage {
        switch style {
        case .light:
            // 未选中：tab_light_plus_icon_unSelected；选中：tab_light_plus_icon_selected
            let image = isSelected
                ? FTTabR.image.tab_LIGHT_PLUS_SELECTED
                : FTTabR.image.tab_LIGHT_PLUS_UN_SELECTED
            return image.withRenderingMode(.alwaysOriginal)
        case .dark:
            return FTTabR.image.tab_DARK_PLUS.withRenderingMode(.alwaysOriginal)
        }
    }
    
    // 浅色默认图标
    private func lightStyleDefaultImage(tab: AppTab, isSelected: Bool) -> UIImage {
        var resImage: UIImage
        
        switch tab {
        case .chat:
            resImage = isSelected ? FTTabR.image.tab_LIGHT_IM_SELECTED : FTTabR.image.tab_LIGHT_IM_UN_SELECTED
        case .video:
            resImage = isSelected ? FTTabR.image.tab_LIGHT_VIDEO_SELECTED : FTTabR.image.tab_LIGHT_VIDEO_UN_SELECTED
        case .ai:
            resImage = plusIcon(style: .light, isSelected: isSelected)
        case .mall:
            resImage = isSelected ? FTTabR.image.tab_LIGHT_MALL_SELECTED : FTTabR.image.tab_LIGHT_MALL_UN_SELECTED
        case .me:
            resImage = isSelected ? FTTabR.image.tab_LIGHT_ME_SELECTED : FTTabR.image.tab_LIGHT_ME_UN_SELECTED
        }
        return resImage.withRenderingMode(.alwaysOriginal)
    }
    
    // 深色默认图标
    private func darkStyleDefaultImage(tab: AppTab, isSelected: Bool) -> UIImage {
        var resImage: UIImage
        
        switch tab {
        case .chat:
            resImage = isSelected ? FTTabR.image.tab_DARK_IM_SELECTED : FTTabR.image.tab_DARK_IM_UN_SELECTED
        case .video:
            resImage = isSelected ? FTTabR.image.tab_DARK_VIDEO_SELECTED : FTTabR.image.tab_DARK_VIDEO_UN_SELECTED
        case .ai:
            resImage = plusIcon(style: .dark, isSelected: isSelected)
        case .mall:
            resImage = isSelected ? FTTabR.image.tab_DARK_MALL_SELECTED : FTTabR.image.tab_DARK_MALL_UN_SELECTED
        case .me:
            resImage = isSelected ? FTTabR.image.tab_DARK_ME_SELECTED : FTTabR.image.tab_DARK_ME_UN_SELECTED
        }
        
        return resImage.withRenderingMode(.alwaysOriginal)
    }
}

extension AppTab {
    static let defaultConfigOrder: [AppTab] = [.chat, .video, .ai, .mall, .me]
}



