//
//  PYToolView.h
//  Prome
//
//  Created by 李鹏跃 on 17/2/9.
//  Copyright © 2017年 品一. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYToolBarView : UIView

#pragma mark - 初始化

//MARK: ---------------------主要的方法--------------------------
+ (instancetype)toolBarViewWithFrame:(CGRect)frame andOptionStrArray:(NSArray<NSString *> *)optionStrArray;
- (instancetype)initWithFrame:(CGRect)frame andOptionStrArray:(NSArray<NSString *> *)optionStrArray;

/**展示toolBar*/
- (void)show;
/**
 * item描述的集合
 * 这个程序根据这个属性进行划线和分配item
 */
@property (nonatomic,strong) NSArray <NSString *>* optionStrArray;

/**item点击事件回调*/
@property (nonatomic,copy) void(^clickOptionItemBlock)(UIButton *button,NSString *itemText, NSInteger index);
/**选中的item索引*/
@property (nonatomic,assign) NSInteger selectItemIndex;


#pragma mark - lien参数
//--------------------------------------线----------------------
/**线宽*/
@property (nonatomic,assign) CGFloat lienWidth;
/**线高度*/
@property (nonatomic,assign) CGFloat lienHeight;
/**线的颜色集合**/
@property (nonatomic,assign) CGFloat *lienColorArray;
/**线的颜色**/
@property (nonatomic,strong) UIColor *lienColor;


#pragma mark - item参数
//--------------------------------------item信息----------------------

/**选项item的宽度*/
@property(nonatomic,assign) CGFloat optionWidth;
/**储存了optionItem的坐标及大小*/
@property (nonatomic,strong) NSArray <NSDictionary *> *optionInfo;
/**
 * 储存了optionItem的button
 * Button的tag值加了1000
 */
@property (nonatomic,strong,readonly) NSArray <UIButton *>* optionItemInfo;

/**点击item后是否变灰*/
@property (nonatomic,assign) BOOL showsTouchWhenHighlighted;

/**item的颜色*/
@property (nonatomic,strong) UIColor *itemTextColor_Select;
@property (nonatomic,strong) UIColor *itemTextColor_Normal;
@property (nonatomic,strong) UIColor *itemTextColor_Highlighted;
/**item的text font*/
@property (nonatomic,strong) UIFont *itemTextFont;


#pragma mark - 其他设置
/**button是否可以重复点击*/
@property (nonatomic,assign) BOOL isRecurClickItem;



#pragma mark - itemBottomBarView
 /*
  item默认的底部的barView
   view默认是隐藏的
   view具有默认样式
 */
@property (nonatomic,assign) CGFloat itemBottomBarViewWidth;//距离两边的距离，宽度默认与item等宽
@property (nonatomic,assign) CGFloat itemBottomBarViewHeight;//高度默认是2dp
//颜色默认蓝(r:0.29 g:0.56 b:0.89 a:1.00)
@property (nonatomic,strong) UIColor *itemBottomBarViewColor;

/**关于item底部的view自定义*/
@property (nonatomic,copy) void(^setUpItemSelectBarViewBlock)(UIButton *button,UIView *barView);



#pragma mark - itemBottomBarView 带动画
/**是否动画*/
@property (nonatomic,assign) BOOL isAnima_ItemBottomBarView;
/**动画的时长*/
@property (nonatomic,assign) CGFloat animaTime_ItemBottomBarView;
/**自定义TimeButtonBar动画 - 可以定义选中的tiem的动画*/
//开始
@property (nonatomic,copy) void (^animaItemButtonBarAnima_start)(UIButton *animaView);
//完成
@property (nonatomic,copy) void (^animaItemButtonBarAnima_completion)(UIButton *animaView);

/**item底部的动画的view*/
@property (nonatomic,strong) UIView *itemBarAnimaView;
/**动画view的颜色*/
@property (nonatomic,strong) UIColor *itemBarAnimaViewColor;

@end
