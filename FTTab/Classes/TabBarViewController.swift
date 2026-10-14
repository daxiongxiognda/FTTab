//
//  TabBarViewController.swift
//  FTTab
//
//  Created by 熊坤鹏 on 2026/9/8.
//

import UIKit
import FTBase

public class TabBarViewController: UITabBarController {
  
    let customTabBar = TabBar()
    public let tabConfig = TabConfig()
    private var displayedTabs: [AppTab] = AppTab.defaultConfigOrder
    private var previousTab: AppTab = .chat
    private var lastSelectedDate: Date?
    public private(set) static var instance: TabBarViewController?
    public static func createTabController() -> TabBarViewController {
        instance = nil
        let temp = TabBarViewController()
        instance = temp
        temp.prefersNavigationBarHidden = true
        return temp
    }
    
    // 销毁tab
    public static func destroy() {
        instance = nil
    }
    // Tab事件观察者
    internal var tabObservers = NSPointerArray.weakObjects()
    public func addTabEventObserver(_ observer: TabHandable) {
        tabObservers.ft.addObject(observer)
    }
    public func clearTabObserver() {
        tabObservers.compact()
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBars()
        applyTabConfiguration(preferredTab: .chat)
    }
    
    private func applyTabConfiguration(preferredTab: AppTab) {
        let oldControllers = viewControllers ?? []
        var controllersByTab: [AppTab: UIViewController] = [:]
        for (index, tab) in displayedTabs.enumerated() where oldControllers.indices.contains(index) {
            controllersByTab[tab] = oldControllers[index]
        }

        let newTabs = tabConfig.orderedTabs
        let newControllers = newTabs.map { tab in
            controllersByTab[tab] ?? makeViewController(for: tab)
        }
        displayedTabs = newTabs
        viewControllers = newControllers

        let targetTab = preferredTab
        let targetIndex = index(for: targetTab)
        selectedIndex = targetIndex

        customTabBar.tabConfig = tabConfig
        customTabBar.setItems(makeFloatingTabItems(for: targetTab), selectedIndex: targetIndex)
     
    }
    
    private func makeFloatingTabItems(for selectedTab: AppTab) -> [FloatingTabItem] {
        let style = FTTabBarStyle.light
        return displayedTabs.map { tab in
            FloatingTabItem(
                icon: tabConfig.tabBarItemImage(tab: tab, selectedIndex: -1, style: style),
                selectedIcon: tabConfig.tabBarItemImage(tab: tab, selectedIndex: index(for: tab), style: style),
                isPlus: tab == .ai
            )
        }
    }
    
    public func index(for tab: AppTab) -> Int {
        displayedTabs.firstIndex(of: tab) ?? tab.index
    }
     
    private func makeViewController(for tab: AppTab) -> UIViewController {
        switch tab {
        case .chat:
            return createVC(with: "FTFirstModule.FTIMViewController")
        case .video:
            return createVC(with: "FTSecondModule.FTVideoViewController")
        case .ai:
            return createVC(with: "FTThirdModule.FTAIViewController")
        case .mall:
            return createVC(with: "FTFourthModule.FTMallViewController")
        case .me:
            return createVC(with: "FTFifthModule.FTMeViewController")
        }
    }
    
    // 增加拓展isFromBaseNavVC 是否基于baseNavc
    func createVC(with vcName: String, isFromBaseNavVC: Bool = true) -> UIViewController {
        let cls: AnyClass
        if let resolvedClass = NSClassFromString(vcName) {
            cls = resolvedClass
        } else {
            cls = UIViewController.self
        }
        if let vcType = cls as? UIViewController.Type {
            if isFromBaseNavVC == false {
                return vcType.init()
            }
            return BaseNavigationController(rootViewController: vcType.init())
        } else {
            fatalError("vcName出错，检查是否添加Module名")
        }
    }
    
    private func setupTabBars() {
        customTabBar.floatingDelegate = self
        setValue(customTabBar, forKey: "tabBar")
        customTabBar.style = .light
    }
    
}

extension TabBarViewController: FloatingTabBarDelegate {
    // MARK: - TabBar Delegate 回调

    /// 用户点击了 TabBar 上的某个 item。
    /// - Parameters:
    ///   - tabBar: 触发事件的 TabBar。
    ///   - index: 被点击的 item 在 `displayedTabs` 中的下标。
    public func floatingTabBar(_ tabBar: TabBar, didSelectItemAt index: Int) {
        // 越界保护：下标必须落在 displayedTabs 有效范围内
        guard displayedTabs.indices.contains(index) else { return }
        let tab = displayedTabs[index]
        // 转发到统一的点击处理逻辑，并允许发出点击事件
        clickTabbarItem(tab: tab, emitClickEvent: true)
    }

    
    /// 处理某个 tab 的点击（统一的选中/双击/单击逻辑入口）。
    /// - Parameters:
    ///   - tab: 被点击的 tab。
    ///   - emitClickEvent: 是否向外发出点击事件通知。默认 false（仅做内部状态切换）。
    public func clickTabbarItem(tab: AppTab, emitClickEvent: Bool = false) {
        // 记录当前选中项 这一行就是切换页面的关键代码
        selectedIndex = index(for: tab)

        // 情况一：点击的是「已经选中的同一个 tab」——判定单击 / 双击
        guard previousTab != tab else {
            // 距上次点击在 0.4s 内 → 判定为双击，否则为单击
            if let lastSelectedDate = lastSelectedDate,
               abs(lastSelectedDate.timeIntervalSinceNow) <= 0.4 {
                if emitClickEvent {
                    // 发送双击事件
                    tabHandableEmit(event: .click(tab: tab, clickType: .double))
                }
            } else {
                if emitClickEvent {
                    // 发送单击事件
                    tabHandableEmit(event: .click(tab: tab, clickType: .single))
                }
            }
            // 更新点击时间戳，用于下次判定单击/双击
            self.lastSelectedDate = Date()
            return
        }

        // 情况二：点击的是「不同的 tab」——正常切换
        lastSelectedDate = Date()

        switch tab {
        case .mall:
            // mall tab 不做额外处理（保持原有行为）
            print("")
        default:
            // 非 mall tab：应用对应的 bar 样式
            applyBarStyle(for: tab)
        }

        // 记录上一次选中的 tab
        previousTab = tab
    }
    
    private func applyBarStyle(for tab: AppTab) {
        let style = tabConfig.preferredBarStyle(for: tab)
        customTabBar.style = style
        changeNormalImage(style: style)
    }
    
    func changeNormalImage(style: FTTabBarStyle) {
        for button in customTabBar.tabButtons {
            guard displayedTabs.indices.contains(button.tag) else { continue }
            let tab = displayedTabs[button.tag]
            if tab == .ai {
                continue
            }
            button.setImage(tabConfig.tabBarItemImage(tab: tab, selectedIndex: -1, style: style), for: .normal)
            button.setImage(tabConfig.tabBarItemImage(tab: tab, selectedIndex: index(for: tab), style: style), for: .selected)
        }
    }
    
    ///
    /// - 说明：
    ///   - `tabObservers` 是弱引用指针数组，遍历时逐个取回对象并强转 `TabHandable`；
    ///     已释放（nil 槽位）或类型不匹配的观察者会被跳过。
    ///   - 事件分发切到主线程，保证 UI 相关回调在主线程执行。
    /// - Parameter event: 要广播的 Tab 事件。
    func tabHandableEmit(event: TabEvent) {
        DispatchQueue.main.async {
            // 遍历所有弱引用观察者
            for index in 0..<self.tabObservers.count {
                // 取回对象：nil 槽位 / 非 TabHandable 直接跳过
                guard let observer = self.tabObservers.ft.object(at: index) as? TabHandable else {
                    continue
                }

                // 按事件类型分发给观察者
                switch event {
                case .click(let tab, let type):
                    // 点击事件：转发 tab 与点击类型（单击/双击）
                    observer.clicked(tab: tab, clickType: type)

                case .tabConfigLoaded:
                    // tab 配置加载完成
                    observer.tabConfigLoaded()

                case .pageConfigLoaded(let from, let tab):
                    // 页面配置加载完成
                    observer.pageConfigLoaded(from: from, tab: tab)

                default:
                    // 预留：未处理的事件类型忽略
                    break
                }
            }
        }
    }

}
