//
//  TabBarViewController+MiniApp.swift
//  FTTab
//
//  Created by 熊坤鹏 on 2026/10/8.
//

import Foundation

/// 可接收 Tab 相关事件的观察者协议。
///
/// 任何需要监听 TabBar / Tab 配置等事件的类型，遵循此协议并注册到
/// `tabObservers` 后，即可收到对应回调。
///
/// - 说明：
///   - 继承 `AnyObject`，限定只能由**类**实现，便于配合弱引用数组（`NSPointerArray.weakObjects()`）使用，避免循环引用。
///   - 所有方法在 `public extension` 中提供了**默认空实现**，遵循者可按需只实现关心的方法。
public protocol TabHandable: AnyObject {

    /// Tab 被点击时回调。
    /// - Parameters:
    ///   - tab: 被点击的 tab。
    ///   - clickType: 点击类型（单击 / 双击）。
    func clicked(tab: AppTab, clickType: TabClickType)

    /// Tab 配置加载完成时回调。
    func tabConfigLoaded()

    /// 页面配置加载完成时回调。
    /// - Parameters:
    ///   - from: 配置数据来源。
    ///   - tab: 关联的 tab；可能为 nil（表示与具体 tab 无关）。
    func pageConfigLoaded(from: PageConfigDataFrom, tab: AppTab?)
}

/// `TabHandable` 的默认实现。
///
/// 为所有方法提供**空实现**，遵循者只需实现自己关心的方法，
/// 无需为不关心的事件写空方法。
public extension TabHandable {

    /// 默认空实现：不处理点击事件。
    func clicked(tab: AppTab, clickType: TabClickType) {}

    /// 默认空实现：不处理 tab 配置加载完成事件。
    func tabConfigLoaded() {}

    /// 默认空实现：不处理页面配置加载完成事件。
    func pageConfigLoaded(from: PageConfigDataFrom, tab: AppTab?) {}
}
