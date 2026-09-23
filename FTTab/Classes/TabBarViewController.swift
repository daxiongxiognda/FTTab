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
    
    public private(set) static var instance: TabBarViewController?
    public static func createTabController() -> TabBarViewController {
        instance = nil
        let temp = TabBarViewController()
        instance = temp
        temp.prefersNavigationBarHidden = true
        return temp
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
    public func floatingTabBar(_ tabBar: TabBar, didSelectItemAt index: Int) {
        
    }
}
