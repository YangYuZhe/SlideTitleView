//
//  SlideTitleView.swift
//  ChouTi
//
//  Created by 杨雨哲 on 2017/11/8.
//  Copyright © 2017年 com.longdai. All rights reserved.
//

import UIKit

private let kMargin: CGFloat = 3
private let kSlideBarHeight:CGFloat = 1.5

protocol SlideTitleViewDelegate {
    func titleViewDidSelectedIndex(index:Int)
}

class SlideButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            bottomLabel.isHidden = !isSelected
        }
    }
    
    let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = fontWithSize(10)
        label.textColor = CTColor.colors.ct_pullDownMenuTitleColor
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitleColor(CTColor.colors.ct_pullDownMenuTitleColor, for: .normal)
        self.setTitleColor(CTColor.colors.ct_digListCellTitleColor, for: .selected)
        self.titleLabel?.font = fontWithSize(14)
        self.adjustsImageWhenHighlighted = false
        self.addSubview(bottomLabel)
    }
    
    func setBottomTitle(title:String?) {
        bottomLabel.text = title
        if let titleString = title {
            let size = NSString(string:titleString).size(withAttributes: [NSAttributedStringKey.font : fontWithSize(10)])
            bottomLabel.frame = CGRect(x: (self.titleLabel?.frame.maxX)! + 3, y: (self.titleLabel?.frame.maxY)! - size.height , width: size.width, height: size.height)
        }
    }
    
    func bottomTitle() -> String{
        if let title = bottomLabel.text {
            return title
        }else {
            return ""
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SlideTitleView: UIView {
    
    var delegate: SlideTitleViewDelegate?
    
    // 当前选中的按钮
    private var selectedButton:UIButton?
    
    private var buttons = [SlideButton]()

    // 滑动条
    let slideBar:UIView = {
        let bar = UIView()
        bar.backgroundColor = .black
        return bar
    }()
    
    init(frame: CGRect, titles:[String]) {
        super.init(frame: frame)
        
        let buttonWidth = frame.size.width/CGFloat(titles.count)
        let buttonHeight = frame.size.height
        
        for index in 0..<titles.count {
            let title = titles[index]
            
            let button = SlideButton(frame: CGRect(x: buttonWidth*CGFloat(index) , y: 0, width: buttonWidth, height: buttonHeight))
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
            self.addSubview(button)
            buttons.append(button)
            
        }

        self.addSubview(slideBar)
    }
    
    // 按钮被点击
    @objc private func buttonClicked(sender:UIButton) {

        if let preButton = selectedButton {
            if preButton != sender {
                
                // 动画
                let buttonFrame = sender.frame
                var barFrame = self.slideBar.frame
                barFrame.origin.x = buttonFrame.origin.x + (buttonFrame.size.width - widthOfTitle(title: sender.title(for: .normal)!, fontSize:14))/2.0
                barFrame.size = CGSize(width: self.widthOfTitle(title: sender.title(for: .normal)!, fontSize:14) + self.widthOfTitle(title: (sender as! SlideButton).bottomTitle(), fontSize:10) + 3, height: barFrame.size.height)
                UIView.animate(withDuration: 0.2, animations: {
                    self.slideBar.frame = barFrame
                })
                
                // 处理新旧按钮
                preButton.isSelected = false
                sender.isSelected = true
                selectedButton = sender
                if let index = buttons.index(of: selectedButton as! SlideButton) {
                    delegate?.titleViewDidSelectedIndex(index: index)
                }
            }
        }else {
            sender.isSelected = true
            selectedButton = sender
            
            let buttonFrame = sender.frame
            slideBar.frame = CGRect(x:buttonFrame.origin.x + (buttonFrame.size.width - widthOfTitle(title: sender.title(for: .normal)!, fontSize:14))/2.0 , y: buttonFrame.size.height - kSlideBarHeight, width: widthOfTitle(title: sender.title(for: .normal)!, fontSize:14), height: kSlideBarHeight)
            
            if let index = buttons.index(of: selectedButton as! SlideButton) {
                delegate?.titleViewDidSelectedIndex(index: index)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SlideTitleView {
    
    // 计算文本长度
    private func widthOfTitle(title:String, fontSize:CGFloat) -> CGFloat {
        return NSString(string:title).size(withAttributes: [NSAttributedStringKey.font : fontWithSize(fontSize)]).width
    }
    
    // 外部事件联动选择按钮
    func selectIndex(index:Int) {
        let button = buttons[index]
        self.buttonClicked(sender: button)
    }

    // 给按钮的小标签文本赋值
    func setBottomTitleForIndex(index:Int, title:String) {
        let button = buttons[index]
        
        // 外面这层判断是防止其他按钮的文本长度计算干扰到当前的按钮下的bar长度
        if button == selectedButton {
            var barFrame = slideBar.frame
            let titleWidth = self.widthOfTitle(title: title, fontSize:10)
            let oldTitleWidth = self.widthOfTitle(title: button.bottomTitle(), fontSize:10)
            
            if titleWidth != oldTitleWidth {
                barFrame.size = CGSize(width: self.widthOfTitle(title: button.title(for: .normal)!, fontSize:14) + titleWidth + 3, height: barFrame.size.height)
                UIView.animate(withDuration: 0.2, animations: {
                    self.slideBar.frame = barFrame
                })
            }
        }
        
        button.setBottomTitle(title: title)
    }
}
