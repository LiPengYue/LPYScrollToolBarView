//
//  LPYScrollTollBarView.h
//  PYMYHomePage
//
//  Created by 李鹏跃 on 17/2/17.
//  Copyright © 2017年 13lipengyue. All rights reserved.
//


/*--------------------------- ~readMe~ ---------------------------*/
/**
 * 注意： 这个类并不完美，他的BackGroundScrollView的contentOffset是根据其子类的scrollView的contentOffset来设置的
 *   在设置BackGroundScrollView的contentOffset的通知干改变了bottomScrollView的frame
 */



#import <UIKit/UIKit.h>
#import "PYToolBarView.h"

@interface LPYScrollToolBarView : UIView

@property (nonatomic,assign) CGSize scrollToolBarViewContentSize;

- (instancetype)initWithFrame:(CGRect)frame andToolBarViewHeight: (CGFloat)toolBarViewHeight andTopViewHeight: (CGFloat)topViewHeight;

- (instancetype)initWithFrame:(CGRect)frame
         andToolBarViewHeight:(CGFloat)toolBarViewHeight
             andTopViewHeight:(CGFloat)topViewHeight
                   andToolBar: (PYToolBarView *)toolBarView
                   andTopView:(UIView *)topView
             andBottomViewSet:(NSArray <UIView *>*)viewArray;


/**UI界面的展示*/
- (void)show;

 
#pragma mark - -----------topView的设置------------
/**topView的高度*一定要设置*/
@property (nonatomic,assign) CGFloat topViewHeight;



#pragma mark - -----------ToolBarView的设置------------
//toolBarView 的宽高通过toolBarViewHeight 设置
/**不用设置其frame，只需设置其样式*/
@property (nonatomic,strong) PYToolBarView *toolBarView;
/**菜单栏的高度*这个必须要用到而且必须要在一开始设置*/
@property (nonatomic,assign) CGFloat toolBarViewHeight;
/**横向的间距*/
@property (nonatomic,assign) CGFloat toolBarViewCrosswiseMargin;
/**
 * selectView: toolBar选中的item对应的View
 * 如果获取toolBar点击事件 那么用这个方法
 * name: toolBar item的描述
 */
@property (nonatomic,copy) void(^clickToolBarViewBlock)(UIButton *toolBarItem,UIView *selectView,NSString *name,NSInteger index);




#pragma mark -------------bottomScrollView的View集合
/**下部scrollView的集合*/
@property (nonatomic,strong) NSArray <UIView *>*bottomScrollViewArray;
/**下部的scrollView中的subView的宽度比例*/
@property (nonatomic,assign) CGFloat bottomScrollViewContentViewScale;
/**bottomView 是否支持分页*/
@property (nonatomic,assign) BOOL pagingEnabled;
/**选中的toolBar的index*/
@property (nonatomic,assign,readonly) NSInteger selectViewPage;
/**移动底部的scrollView的时候调用*/
@property (nonatomic,copy) void(^scrollBottomViewBlock)(NSInteger page,CGPoint contentOffset);
/**设置偏移页数*/
@property (nonatomic,assign) NSInteger scrollBottomViewPage;


#pragma mark ------------- 下拉到顶的时候 上部动画时长 -----
/**下拉到顶的时候 上部动画时长.默认0.3秒*/
@property (nonatomic,assign) CGFloat animaDownTime;
/**上滚的时候的动画时长*/
@property (nonatomic,assign) CGFloat animaUpTime;
/**从什么时候开始上拉动画（相对于topView比例 默认0 [0,0.5]*/
@property (nonatomic,assign) CGFloat animaUpScale;



#pragma mark -------------- 滚动条
@property (nonatomic,assign) BOOL backgroundViewShowVerticalScrollIndicator;
@property (nonatomic,assign) BOOL backgroundViewShowHorizontalScrollIndicator;
@property (nonatomic,assign) BOOL bottomViewHorizontalScrollIndicator;
@property (nonatomic,assign) BOOL bottomViewShowVerticalScrollIndicator;



#pragma mark - ------------手势
//注意设置了就要调用show方法 才能起作用
//预留接口，现在还没有实现
@property (nonatomic,assign) BOOL openToolBarGestureRecognizer;
@property (nonatomic,assign) BOOL openTopViewGestureRecognizer;
@property (nonatomic,assign) BOOL openBottomScrollViewGestureRecognizer;
@property (nonatomic,assign) BOOL openAllViewGestureRecognizer;
@end
