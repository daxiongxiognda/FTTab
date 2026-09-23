//
//  TabBar.swift
//  FTTab
//
//  Created by 熊坤鹏 on 2026/9/8.
//

import UIKit
import RxSwift
import FTTool

public class TabBar: UITabBar {
    private let disposeBag = DisposeBag()
    var style: FTTabBarStyle = .light {
        didSet {
            switch style {
            case .light:
                configuration.backgroundBlurStyle = .systemUltraThinMaterialLight
                // 白色叠加透明度再加 20%：0.3 → 0.5，降低通透感
                configuration.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                // 白色主题背景模糊 100%
                configuration.backgroundBlurIntensity = 1.0
                configuration.normalTextColor = .black
                configuration.selectedTextColor = .white
            case .dark:
                configuration.backgroundBlurStyle = .systemUltraThinMaterialDark
                // 黑色叠加透明度加 20%：0.45 → 0.65
                configuration.backgroundColor = UIColor.black.withAlphaComponent(0.65)
                // 黑色主题背景模糊 100%
                configuration.backgroundBlurIntensity = 1.0
                configuration.normalTextColor = .white
                configuration.selectedTextColor = .black
            }
            updatePlusAppearance()
            updateAppearance()
            pinSelectionIndicatorToPlus(animated: false)
            setNeedsLayout()
        }
    }
    public weak var floatingDelegate: FloatingTabBarDelegate?
    var allItems: [FloatingTabItem] = []
    var tabButtons: [UIButton] = []
    private(set) var oldIndex: Int = 0
    private(set) var selectedIndex: Int = 0
    var tabConfig: TabConfig?
    
    init(configuration: FloatingTabBarConfiguration = FloatingTabBarConfiguration()) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        clipsToBounds = false
        layer.masksToBounds = false
        backgroundColor = .clear
        backgroundImage = UIImage()
        isTranslucent = true
        shadowImage = UIImage()
        
        addSubview(selectionIndicatorView)
        addSubview(backgroundBlurView)

        backgroundBlurView.layer.mask = backgroundMaskLayer

        updateAppearance()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        for subview in self.subviews {
            let className = NSStringFromClass(subview.classForCoder)
            if className.contains("UITabBarButton") {
                subview.isHidden = true
                subview.alpha = 0
            }
        }
    }
    
    //创建5个Button
    func setItems(_ items: [FloatingTabItem], selectedIndex: Int = 0) {
        self.allItems = items
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()
        
        for (index, item) in items.enumerated() {
            let button = createTabButton(for: item, at: index)
            addSubview(button)
            tabButtons.append(button)
        }

        let safeSelectedIndex = items.indices.contains(selectedIndex) ? selectedIndex : 0
        oldIndex = safeSelectedIndex
        self.selectedIndex = safeSelectedIndex
        updateButtonSelectionStates()
        updatePlusAppearance()
        pinSelectionIndicatorToPlus(animated: false)
        setNeedsLayout()
    }
    
    private func updateButtonSelectionStates() {
        // 1. 遍历所有 Tab 按钮
        tabButtons.forEach { button in
            
            // 2. 判断当前按钮是否是“加号”按钮
            //    先检查索引是否越界，再检查该位置的 item 是否是 plus 类型
            let isPlus = allItems.indices.contains(button.tag) && allItems[button.tag].isPlus
            
            // 3. 设置按钮的选中状态
            button.isSelected = button.tag == selectedIndex
            
            // 4. 根据是否是加号按钮，设置不同的 tintColor
            if isPlus {
                // 加号按钮：tintColor 设为透明（因为它使用图片原色，不需要 tintColor 着色）
                button.tintColor = .clear
            } else {
                // 普通按钮：选中时用 selectedTextColor，未选中时用 normalTextColor
                button.tintColor = button.isSelected ? configuration.selectedTextColor : configuration.normalTextColor
            }
        }
    }
    
    //创建tabbar按钮
    private func createTabButton(for item: FloatingTabItem, at index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.tag = index
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)

        if item.isPlus {
            let plusImage = item.icon ?? item.selectedIcon
            let plusSelected = item.selectedIcon ?? item.icon
            button.setImage(plusImage, for: .normal)
            button.setImage(plusSelected, for: .selected)
            button.tintColor = .clear
        } else {
            if let icon = item.icon {
                button.setImage(icon.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            if let selectedIcon = item.selectedIcon {
                button.setImage(selectedIcon.withRenderingMode(.alwaysOriginal), for: .selected)
            }
            button.tintColor = configuration.normalTextColor
        }

        button.setTitle("", for: .normal) // 清空文字（关键：避免 Label 占位）
        button.titleLabel?.isHidden = true // 隐藏 Label
        button.titleLabel?.frame = .zero // 强制 Label 尺寸为 0（双重保险）
        button.imageView?.contentMode = .scaleAspectFit
        button.adjustsImageWhenHighlighted = false
        button.adjustsImageWhenDisabled = false
        
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.imageEdgeInsets = .zero
        
        return button
    }
    @objc private func tabButtonTapped(_ sender: UIButton) {
        setSelectedIndex(sender.tag, animated: true)
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool) {
        guard index >= 0 && index < allItems.count else { return }
        layoutSubviews()
        
        oldIndex = selectedIndex
        selectedIndex = index
        updateButtonSelectionStates()
        updatePlusBackfillAppearance()
        floatingDelegate?.floatingTabBar(self, didSelectItemAt: index)
    }

    private func updatePlusAppearance() {
        for (index, button) in tabButtons.enumerated() {
            guard allItems.indices.contains(index), allItems[index].isPlus else { continue }
            let normalImage = tabConfig?.plusIcon(style: style, isSelected: false)
                ?? allItems[index].icon
                ?? allItems[index].selectedIcon
            let selectedImage = tabConfig?.plusIcon(style: style, isSelected: true)
                ?? allItems[index].selectedIcon
                ?? allItems[index].icon
                ?? normalImage
            button.setImage(normalImage, for: .normal)
            button.setImage(selectedImage, for: .selected)
            button.setImage(selectedImage, for: .highlighted)
            button.tintColor = .clear
        }
        setNeedsLayout()
    }
    private var plusIndex: Int {
        // 1. 查找第一个 isPlus == true 的项的索引
        if let index = allItems.firstIndex(where: { $0.isPlus }) {
            return index
        }
        
        // 2. 如果没找到（数组中没有 isPlus 项）：
        //    - 如果数组为空，返回 0
        //    - 否则返回数组中间位置的索引
        return allItems.isEmpty ? 0 : allItems.count / 2
    }
    
    private var isPlusSelected: Bool {
        return selectedIndex == plusIndex
    }
    
    private var shouldShowPlusBackfill: Bool {
        style == .light
    }
    
    private func pinSelectionIndicatorToPlus(animated: Bool) {
        // 1. 如果不应该显示加号回填，或者按钮数组为空，直接隐藏指示器并重置遮罩
        guard shouldShowPlusBackfill, !tabButtons.isEmpty else {
            selectionIndicatorView.isHidden = true
            backgroundMaskLayer.path = createMaskPath(holeFrame: .zero).cgPath
            return
        }
        
        // 2. 确保指示器可见
        selectionIndicatorView.isHidden = false
        
        // 3. 将指示器从 plusIndex 更新到 plusIndex（即固定在加号位置）
        updateSelectionIndicator(from: plusIndex, to: plusIndex, animated: animated)
        
        // 4. 更新加号回填的外观（颜色、模糊等）
        updatePlusBackfillAppearance()
    }
    
    private func createMaskPath(holeFrame: CGRect) -> UIBezierPath {
        // 1. 安全检查：如果背景模糊视图的宽高为 0，返回一个空路径，避免无效计算
        guard backgroundBlurView.bounds.width > 0 && backgroundBlurView.bounds.height > 0 else {
            return UIBezierPath(rect: .zero)
        }
        
        // 2. 创建整个背景的圆角矩形路径（遮罩的基础形状）
        let fullPath = UIBezierPath(roundedRect: backgroundBlurView.bounds,
                                    cornerRadius: configuration.cornerRadius)
        
        // 3. 如果“洞”的尺寸有效，创建洞的路径并附加到主路径上
        if holeFrame.width > 0 && holeFrame.height > 0 {
            let holePath = UIBezierPath(roundedRect: holeFrame,
                                        cornerRadius: holeFrame.height / 2)
            fullPath.append(holePath)
        }
        
        // 4. 返回最终路径
        return fullPath
    }
    
    
    private func updatePlusBackfillAppearance() {
        // 1. 只有需要显示加号回填时才继续
        guard shouldShowPlusBackfill else { return }
        
        // 2. 将遮罩层的圆角设置为指示器高度的一半（即圆形/胶囊形）
        selectionIndicatorOverlay.layer.cornerRadius = selectionIndicatorView.bounds.height / 2
        
        // 3. 根据是否选中加号，设置不同的遮罩颜色
        if isPlusSelected {
            // 选中加号时：白色模式，保留高斯模糊，叠加更深的遮罩（72% 不透明度的黑色）
            selectionIndicatorOverlay.backgroundColor = UIColor(0x010101).withAlphaComponent(0.72)
        } else {
            // 未选中加号时：使用较浅的遮罩（28% 不透明度的黑色）
            selectionIndicatorOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        }
        
        // 4. 重新设置选中模糊效果
        setupSelectionBlur()
    }
    
    private var plusBackfillSize: CGSize {
        configuration.plusItemSize
    }
    
    private func updateSelectionIndicator(from oldIndex: Int, to newIndex: Int, animated: Bool) {
        // 1. 更新所有按钮的选中状态
        updateButtonSelectionStates()
        
        // 2. 找到目标按钮（根据 tag 匹配 newIndex）
        guard let targetButton = tabButtons.first(where: { $0.tag == newIndex }) else { return }
        
        // 3. 计算目标按钮在 backgroundBlurView 坐标系中的中心点
        let plusSize = plusBackfillSize
        let buttonCenterInBlurView = convert(targetButton.center, to: backgroundBlurView)
        
        // 4. 计算在 backgroundBlurView 坐标系中的“洞”的 frame
        let holeFrameInBlurView = CGRect(
            x: buttonCenterInBlurView.x - plusSize.width / 2,
            y: buttonCenterInBlurView.y - plusSize.height / 2,
            width: plusSize.width,
            height: plusSize.height
        )
        
        // 5. 将“洞”的 frame 转换到指示器所在的坐标系
        let indicatorFrame = CGRect(
            x: holeFrameInBlurView.origin.x + backgroundBlurView.frame.origin.x,
            y: holeFrameInBlurView.origin.y + backgroundBlurView.frame.origin.y,
            width: plusSize.width,
            height: plusSize.height
        )
        
        // 6. 应用计算好的 frame，并更新遮罩层
        applyIndicatorFrame(indicatorFrame, holeFrameInBlurView: holeFrameInBlurView, animated: animated)
    }
    
    /// 应用指示器的 frame（统一入口）
    ///
    /// 根据是否需要动画，决定是直接设置最终状态，还是执行弹簧动画过渡。
    /// 该方法被抽取出来，方便在不同场景下复用（如选中项切换、布局更新等）。
    ///
    /// - Parameters:
    ///   - indicatorFrame: 指示器在 TabBar 坐标系中的目标 frame
    ///   - holeFrameInBlurView: 遮罩层“挖洞”区域在 blurView 坐标系中的 frame
    ///   - animated: 是否需要动画过渡
    private func applyIndicatorFrame(_ indicatorFrame: CGRect, holeFrameInBlurView: CGRect, animated: Bool) {
        if animated {
            // 需要动画：调用弹簧动画方法，平滑过渡到目标状态
            animateSelectionChange(to: indicatorFrame, holeFrameInBlurView: holeFrameInBlurView)
        } else {
            // 不需要动画：直接设置最终状态（用于首次布局或禁用动画的场景）
            
            // 设置指示器的位置和大小
            selectionIndicatorView.frame = indicatorFrame
            
            // 设置圆角为高度的一半，使其呈胶囊形
            selectionIndicatorView.layer.cornerRadius = indicatorFrame.height / 2
            
            // 更新遮罩层路径，在背景上挖出对应大小的洞
            backgroundMaskLayer.path = createMaskPath(holeFrame: holeFrameInBlurView).cgPath
        }
    }
    
    /// 执行液态弹簧动画（动画核心）
    ///
    /// 当选中项切换时，让指示器和背景遮罩以弹簧动画的方式，平滑过渡到新的位置和大小。
    /// 动画包含三部分：指示器位置、指示器尺寸、遮罩路径。
    /// 三者同步执行，确保视觉上是一个整体。
    ///
    /// - Parameters:
    ///   - targetFrame: 指示器在 TabBar 坐标系中的目标 frame
    ///   - holeFrameInBlurView: 遮罩层“挖洞”区域在 blurView 坐标系中的目标 frame
    private func animateSelectionChange(to targetFrame: CGRect, holeFrameInBlurView: CGRect) {
        // MARK: - 1. 获取起始状态
        
        /// 获取指示器当前的实际 frame
        /// 优先使用 presentationLayer，确保动画进行中也能拿到正确的起始位置
        /// 如果动画未进行，则回退到 modelLayer 的 frame
        let startFrame = selectionIndicatorView.layer.presentation()?.frame ?? selectionIndicatorView.frame
        
        /// 将起始 frame 从 TabBar 坐标系转换到 blurView 坐标系
        /// 因为遮罩路径是基于 blurView 的坐标计算的
        let startHoleFrameInBlurView = CGRect(
            x: startFrame.origin.x - backgroundBlurView.frame.origin.x,
            y: startFrame.origin.y - backgroundBlurView.frame.origin.y,
            width: startFrame.width,
            height: startFrame.height
        )
        
        /// 创建起始遮罩路径（从当前状态开始）
        let startPath = createMaskPath(holeFrame: startHoleFrameInBlurView).cgPath
        
        /// 创建结束遮罩路径（到目标状态结束）
        let endPath = createMaskPath(holeFrame: holeFrameInBlurView).cgPath
        
        // MARK: - 2. 设置最终状态（动画会从起始值过渡到此）
        
        /// 设置指示器的最终位置和大小
        selectionIndicatorView.frame = targetFrame
        
        /// 设置圆角为高度的一半，保持胶囊形
        selectionIndicatorView.layer.cornerRadius = targetFrame.height / 2
        
        /// 设置遮罩的最终路径
        backgroundMaskLayer.path = endPath
        
        // MARK: - 3. 读取弹簧配置
        
        /// 弹簧刚度，值越大动画越快、越“硬”
        let stiffness = configuration.springStiffness
        
        /// 阻尼系数，值越大弹跳越少
        let damping = configuration.springDamping
        
        // MARK: - 4. 创建位置弹簧动画
        
        /// 控制指示器位置从 startFrame 到 targetFrame 的弹簧过渡
        let positionAnim = CASpringAnimation(keyPath: "position")
        positionAnim.fromValue = CGPoint(x: startFrame.midX, y: startFrame.midY)
        positionAnim.toValue = CGPoint(x: targetFrame.midX, y: targetFrame.midY)
        positionAnim.stiffness = stiffness
        positionAnim.damping = damping
        positionAnim.mass = 1.0
        positionAnim.initialVelocity = 0
        /// 使用系统自动计算的弹簧稳定时间作为动画时长
        positionAnim.duration = positionAnim.settlingDuration
        
        // MARK: - 5. 创建尺寸弹簧动画
        
        /// 控制指示器尺寸从 startFrame.size 到 targetFrame.size 的弹簧过渡
        let boundsAnim = CASpringAnimation(keyPath: "bounds")
        boundsAnim.fromValue = CGRect(origin: .zero, size: startFrame.size)
        boundsAnim.toValue = CGRect(origin: .zero, size: targetFrame.size)
        boundsAnim.stiffness = stiffness
        boundsAnim.damping = damping
        boundsAnim.mass = 1.0
        /// 注意：此处应使用 boundsAnim 的 initialVelocity，原代码误写为 positionAnim
        boundsAnim.initialVelocity = 0
        boundsAnim.duration = boundsAnim.settlingDuration
        
        // MARK: - 6. 创建遮罩路径弹簧动画
        
        /// 控制遮罩路径从 startPath 到 endPath 的弹簧过渡
        let pathAnim = CASpringAnimation(keyPath: "path")
        pathAnim.fromValue = startPath
        pathAnim.toValue = endPath
        pathAnim.stiffness = stiffness
        pathAnim.damping = damping
        pathAnim.mass = 1.0
        pathAnim.initialVelocity = 0
        pathAnim.duration = pathAnim.settlingDuration
        
        // MARK: - 7. 组合并添加动画
        
        /// 将位置和尺寸动画组合成一个动画组，确保它们同步执行
        let group = CAAnimationGroup()
        group.animations = [positionAnim, boundsAnim]
        group.duration = positionAnim.settlingDuration
        group.timingFunction = CAMediaTimingFunction(name: .linear)
        /// 动画开始前显示起始值，避免图层闪烁
        group.fillMode = .backwards
        selectionIndicatorView.layer.add(group, forKey: "selectionSpring")
        
        /// 将路径动画添加到遮罩图层
        pathAnim.fillMode = .backwards
        backgroundMaskLayer.add(pathAnim, forKey: "maskSpring")
    }
    
    private lazy var selectionIndicatorView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: nil)
        effectView.isUserInteractionEnabled = false
        effectView.layer.cornerRadius = effectView.bounds.height / 2
        effectView.clipsToBounds = true
        selectionIndicatorOverlay.frame = effectView.bounds
        selectionIndicatorOverlay.layer.cornerRadius = effectView.bounds.height / 2
        effectView.contentView.addSubview(selectionIndicatorOverlay)
        return effectView
    }()
    /// TabBar 背景模糊视图容器（带遮罩）
    private lazy var backgroundBlurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: nil) // 初始无效果，由 animator 控制
        view.translatesAutoresizingMaskIntoConstraints = true
        view.layer.cornerRadius = configuration.cornerRadius
        view.clipsToBounds = true
        backgroundColorOverlay.frame = view.bounds
        view.contentView.addSubview(backgroundColorOverlay)
        return view
    }()
    private lazy var backgroundColorOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return overlay
    }()
    private lazy var selectionIndicatorOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return overlay
    }()
    /// 背景遮罩层 - 在选中区域挖洞
    private let backgroundMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = .evenOdd
        return layer
    }()
 
    
    /**
     CAGradientLayer 是一个轻量级、高性能的渐变绘制工具，通过设置颜色数组和方向即可快速实现从简单到复杂的渐变效果。它不依赖图片资源，完全由代码控制，非常适合在需要动态调整颜色或尺寸的场景中使用
     */
    let bgLayer = CAGradientLayer()
    
    public var configuration: FloatingTabBarConfiguration = FloatingTabBarConfiguration() {
        didSet { updateAppearance() }
    }
    
    private func updateAppearance() {
        layer.shadowOpacity = 0
                
        backgroundBlurView.layer.cornerRadius = 0
        backgroundBlurView.layer.masksToBounds = true
        backgroundBlurView.layer.borderWidth = 0
        backgroundColorOverlay.backgroundColor = configuration.backgroundColor
        
        selectionIndicatorView.layer.cornerRadius = selectionIndicatorView.bounds.height / 2
        
        setupBackgroundBlur()
        setupSelectionBlur()
    }
    
    /// 背景模糊动画器
    private var backgroundBlurAnimator: UIViewPropertyAnimator?
    /// 选中模糊动画器
    private var selectionBlurAnimator: UIViewPropertyAnimator?
    
    private func setupBackgroundBlur() {
        // 1. 停止之前的动画，并立即完成到当前状态
        backgroundBlurAnimator?.stopAnimation(true)
        backgroundBlurAnimator?.finishAnimation(at: .current)
        
        // 2. 先清除模糊效果，避免叠加
        backgroundBlurView.effect = nil
        
        // 3. 如果模糊强度为 0，直接返回，不应用模糊
        guard configuration.backgroundBlurIntensity > 0 else { return }
        
        // 4. 创建模糊效果
        let blurEffect = UIBlurEffect(style: configuration.backgroundBlurStyle)
        
        // 5. 创建属性动画器，在动画中设置模糊效果
        backgroundBlurAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
            self?.backgroundBlurView.effect = blurEffect
        }
        
        // 6. 将动画进度设置为配置的强度（0~1 之间）
        backgroundBlurAnimator?.fractionComplete = configuration.backgroundBlurIntensity
        
        // 7. 动画完成后暂停，保持当前模糊状态
        backgroundBlurAnimator?.pausesOnCompletion = true
    }
    
    private func setupSelectionBlur() {
        // 1. 停止之前的动画，并立即完成到当前状态，避免动画冲突
        selectionBlurAnimator?.stopAnimation(true)
        selectionBlurAnimator?.finishAnimation(at: .current)
        
        // 2. 先清除选中指示器的模糊效果，避免叠加
        selectionIndicatorView.effect = nil
        
        // 3. 如果选中模糊强度为 0，直接返回，不应用模糊
        guard configuration.selectionBlurIntensity > 0 else { return }
        
        // 4. 创建固定样式的模糊效果（.regular）
        let blurEffect = UIBlurEffect(style: .regular)
        
        // 5. 创建属性动画器，在动画中设置模糊效果
        //    使用 [weak self] 避免循环引用
        selectionBlurAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
            self?.selectionIndicatorView.effect = blurEffect
        }
        
        // 6. 将动画进度设置为配置的强度（0~1 之间）
        //    例如 0.5 表示 50% 的模糊强度
        selectionBlurAnimator?.fractionComplete = configuration.selectionBlurIntensity
        
        // 7. 动画完成后暂停，保持当前模糊状态
        //    如果不设置，动画会继续执行到 1.0（完全模糊）
        selectionBlurAnimator?.pausesOnCompletion = true
    }
}





public struct FloatingTabItem {
    public let icon: UIImage?
    public let selectedIcon: UIImage?
    public let nornalPagFile: String?
    public let selectPagFile: String?
    public let isPlus: Bool
    
    public init(icon: UIImage? = nil, selectedIcon: UIImage? = nil, nornalPagFile: String? = nil, selectPagFile: String? = nil, isPlus: Bool = false) {
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.nornalPagFile = nornalPagFile
        self.selectPagFile = selectPagFile
        self.isPlus = isPlus
    }
}

@MainActor
public protocol FloatingTabBarDelegate: AnyObject {
    func floatingTabBar(_ tabBar: TabBar, didSelectItemAt index: Int)
}

public struct FloatingTabBarConfiguration {
    /// 未选中字体颜色
    public var normalTextColor: UIColor = .black
    /// 选中字体颜色
    public var selectedTextColor: UIColor = .white
    /// 字体大小
    public var fontSize: CGFloat = 16
    /// 字体粗细
    public var fontWeight: UIFont.Weight = .medium
    /// 背景圆角程度
    public var cornerRadius: CGFloat = 0
    /// 中间图片大小
    public var centerLogoSize: CGSize = CGSize(width: 60, height: 70)
    /// 中间图片向上偏移量
    public var centerLogoTopOffset: CGFloat = 25
    /// 距离屏幕底部距离
    public var bottomPadding: CGFloat = 0
    /// 左右边距（首 item 距左、末 item 距右）
    public var horizontalPadding: CGFloat = 23
    /// Tab 按钮尺寸
    public var tabItemSize: CGSize = CGSize(width: 66, height: 38)
    /// 中间加号整体尺寸（含背透）
    public var plusItemSize: CGSize = CGSize(width: 40, height: 26)
    /// TabBar 高度
    public var tabBarHeight: CGFloat = 50
    /// 是否启用滑动动画
    public var animationEnabled: Bool = true
    /// 动画时长
    public var animationDuration: TimeInterval = 0.3
    /// 选中指示器圆角
    public var selectionIndicatorCornerRadius: CGFloat = 23
    /// 选中指示器垂直边距
    public var selectionIndicatorVerticalPadding: CGFloat = 8
    /// 选中指示器水平边距
    public var selectionIndicatorHorizontalPadding: CGFloat = 8
    /// TabBar 背景模糊样式（样式作为基底，强度由 intensity 控制）
    public var backgroundBlurStyle: UIBlurEffect.Style = .systemUltraThinMaterialLight
    /// 背景模糊强度 (0.0 = 完全透明/无模糊, 1.0 = 完全模糊)
    /// 黑白主题默认 1.0（100%）
    public var backgroundBlurIntensity: CGFloat = 1.0
    /// 背景颜色叠加 (支持透明度)
    public var backgroundColor: UIColor = UIColor.white.withAlphaComponent(0.5)
    /// 选中指示器模糊程度 (0.0 = 完全透明, 1.0 = 完全模糊)
    public var selectionBlurIntensity: CGFloat = 0.22
    
    // MARK: - Shadow & Border
    /// 阴影颜色
    public var shadowColor: UIColor = .black
    /// 阴影不透明度
    public var shadowOpacity: Float = 0
    /// 阴影半径
    public var shadowRadius: CGFloat = 8
    /// 阴影偏移
    public var shadowOffset: CGSize = CGSize(width: 0, height: 4)
    
    /// 边框颜色
    public var borderColor: UIColor = .clear
    /// 边框宽度
    public var borderWidth: CGFloat = 0
    
    // MARK: - Animation
    /// 弹簧动画阻尼 (Damping)
    public var springDamping: CGFloat = 50
    /// 弹簧动画刚度 (Stiffness)
    public var springStiffness: CGFloat = 600
    
    /// 获取配置的字体
    public var font: UIFont {
        return .systemFont(ofSize: fontSize, weight: fontWeight)
    }
    
    public init() {}
}

