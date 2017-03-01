//
//  LPYScrollTollBarView.m
//  PYMYHomePage
//
//  Created by 李鹏跃 on 17/2/17.
//  Copyright © 2017年 13lipengyue. All rights reserved.
//
#import "LPYScrollToolBarView.h"
#import "PYToolBarView.h"

#define kViewWidth self.viewFrame.size.width//整个View的宽度
#define kViewHeight self.viewFrame.size.height //整个view的高度
#define kTopViewHeight self.topView.frame.size.height//上面View的高度
#define kToolBarViewHeight self.toolBarViewHeight//工具分栏的高度


@interface LPYScrollToolBarView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIScrollView *backgroundScrollView;
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,assign) CGRect viewFrame;

//MARK: 底部View内部的scrollview 的subView
@property (nonatomic,strong) UIScrollView *bottomScrollView;
@property (nonatomic,assign) CGFloat contentOffsetY;//记录偏移量（默认是1单位累加）
@property (nonatomic,assign) CGFloat contentOffsetYOld;//记录上次的偏移量
@property(nonatomic,assign) CGFloat contentOffsetNew;//记录新的偏移量
@property (nonatomic,assign) BOOL isFull;//是否拉满了
@property (nonatomic,strong) NSMutableArray *observeScrollViewArray;

@property (nonatomic,assign) BOOL isScrollViewAccomplishScroll;//底部的scrollView是否完成滚动
@end


@implementation LPYScrollToolBarView

#pragma mark - setter
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.viewFrame = frame;
}
- (void)setViewFrame:(CGRect)viewFrame {
    _viewFrame = viewFrame;
}
- (void)setBottomScrollViewArray:(NSArray<UIView *> *)bottomScrollViewArray {
    _bottomScrollViewArray = bottomScrollViewArray;
    [self show];
}
- (void)setPagingEnabled:(BOOL)pagingEnabled {
    _pagingEnabled = pagingEnabled;
    self.bottomScrollView.pagingEnabled = pagingEnabled;
}
- (void)setAnimaUpScale:(CGFloat)animaUpScale {
    if (animaUpScale > 0.5) {
        animaUpScale = .5;
    }
    if (animaUpScale < 0) {
        animaUpScale = 0;
    }
}

#pragma mark - 懒加载
- (UIScrollView *)backgroundScrollView {
    if (!_backgroundScrollView) {
        _backgroundScrollView = [[UIScrollView alloc]init];
    }
    return _backgroundScrollView;
}
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc]init];
    }
    return _topView;
}
- (CGSize)scrollToolBarViewContentSize {
    if (!(_scrollToolBarViewContentSize.height)) {
        _scrollToolBarViewContentSize = CGSizeMake(_scrollToolBarViewContentSize.width,self.topViewHeight + kViewHeight);
    }
    return _scrollToolBarViewContentSize;
}
- (UIScrollView *)bottomScrollView {
    if (!_bottomScrollView) {
        _bottomScrollView = [[UIScrollView alloc]init];
    }
    return _bottomScrollView;
}
- (CGFloat) bottomScrollViewContentViewScale {
    if(!_bottomScrollViewContentViewScale) {
        _bottomScrollViewContentViewScale = 1.0;
    }
    return _bottomScrollViewContentViewScale;
}
- (CGFloat)animaDownTime {
    if (!_animaDownTime) {
        _animaDownTime = 0.2;
    }
    return _animaDownTime;
}
- (CGFloat)animaUpTime {
    if (!_animaUpTime) {
        _animaUpTime = 0.2;
    }
    return _animaUpTime;
}
- (NSMutableArray *)observeScrollViewArray {
    if (!_observeScrollViewArray) {
        _observeScrollViewArray = [[NSMutableArray alloc]init];
    }
    return _observeScrollViewArray;
}

//MARK: ------------------- setter ---------------------
- (void)setOpenAllViewGestureRecognizer:(BOOL)openAllViewGestureRecognizer {
    _openAllViewGestureRecognizer = openAllViewGestureRecognizer;
    if (_openAllViewGestureRecognizer){
        self.openToolBarGestureRecognizer = NO;
        self.openBottomScrollViewGestureRecognizer = NO;
        self.openTopViewGestureRecognizer = NO;
    }
}

- (void)setScrollBottomViewPage:(NSInteger)scrollBottomViewPage {
    _scrollBottomViewPage = scrollBottomViewPage;
    self.bottomScrollView.contentOffset = CGPointMake(self.frame.size.width *self.bottomScrollViewContentViewScale * scrollBottomViewPage, 0);
}
- (void)setToolBarViewHeight:(CGFloat)toolBarViewHeight {
    [self chengeBottomViewFrameWithOffset:CGPointMake(0,toolBarViewHeight - _toolBarViewHeight)];
    _toolBarViewHeight = toolBarViewHeight;
    CGFloat toolBarViewX = _toolBarViewCrosswiseMargin;
    CGFloat toolBarViewY = kTopViewHeight;
    CGFloat toolBarViewW = _toolBarView.frame.size.width;
    CGFloat toolBarViewH = _toolBarViewHeight;
    self.toolBarView.frame =CGRectMake(toolBarViewX, toolBarViewY, toolBarViewW, toolBarViewH);
//    [self show];//重绘
}
- (void)setToolBarViewCrosswiseMargin:(CGFloat)toolBarViewCrosswiseMargin {
    _toolBarViewCrosswiseMargin = toolBarViewCrosswiseMargin;
    CGFloat toolBarViewX = _toolBarViewCrosswiseMargin;
    CGFloat toolBarViewY = kTopViewHeight;
    CGFloat toolBarViewW = kViewWidth - toolBarViewX * 2;
    CGFloat toolBarViewH = kToolBarViewHeight;
    self.toolBarView.frame =CGRectMake(toolBarViewX, toolBarViewY, toolBarViewW, toolBarViewH);
    [self.toolBarView show];
//    [self show];
}

#pragma mark - 构造方法
- (instancetype)initWithFrame:(CGRect)frame andToolBarViewHeight: (CGFloat)toolBarViewHeight andTopViewHeight: (CGFloat)topViewHeight{
    self = [super initWithFrame:frame];
    if (self) {
        self.toolBarViewHeight = toolBarViewHeight;
        self.topViewHeight = topViewHeight;
        self.pagingEnabled = YES;
        self.contentOffsetY = 0;
        [self show];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
         andToolBarViewHeight:(CGFloat)toolBarViewHeight
             andTopViewHeight:(CGFloat)topViewHeight
                   andToolBar: (PYToolBarView *)toolBarView
                   andTopView:(UIView *)topView
             andBottomViewSet:(NSArray <UIView *>*)viewArray{
    self = [super initWithFrame:frame];
    if (self) {
        self.toolBarViewHeight = toolBarViewHeight;
        self.topViewHeight = topViewHeight;
        self.pagingEnabled = YES;
        self.bottomScrollViewArray = viewArray;
        self.topView = topView;
        self.toolBarView = toolBarView;
        self.toolBarView.frame =CGRectMake(0, kTopViewHeight, kViewWidth, self.toolBarViewHeight);
        [self.toolBarView show];
        self.topView.frame = CGRectMake(0, 0, kViewWidth, self.topViewHeight);
        [self show];
    }
    return self;
}

- (void)show {
    //设定初始值
    self.isScrollViewAccomplishScroll = YES;
    //MAKR: 注意，这里的self.subviews是动态的获取子控件，别管坐标了。直接给0
    if (self.subviews.count) {
        //记录子控件的个数，不要直接去取
        NSInteger j = self.subviews.count;
        for (NSInteger i = 0; i < j; i ++) {
            //直接取第0个元素，不然会数组越界
            [self.subviews[0] removeFromSuperview];
        }
    }
    self.openToolBarGestureRecognizer = NO;
    self.openTopViewGestureRecognizer = NO;
    self.openAllViewGestureRecognizer = NO;
    self.openBottomScrollViewGestureRecognizer = NO;
    [self setupUI];
}

#pragma mark - 布局界面
- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];

    [self setupBackgrundScrollView];
    [self setupTopView];
    [self setupToolBarView];
    [self setupBottomView];
}

- (void)setupBackgrundScrollView {
    [self addSubview:self.backgroundScrollView];
    if (self.openAllViewGestureRecognizer) {
        //添加pan手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [self.backgroundScrollView addGestureRecognizer:pan];
    }
    self.backgroundScrollView.frame = self.viewFrame;
    self.backgroundScrollView.delegate = self;
    self.backgroundScrollView.bounces = NO;
    self.backgroundScrollView.showsVerticalScrollIndicator = self.backgroundViewShowVerticalScrollIndicator;
    self.backgroundScrollView.showsHorizontalScrollIndicator = self.backgroundViewShowHorizontalScrollIndicator;
}
- (void)setupTopView {
    [self.backgroundScrollView addSubview:self.topView];
    //添加pan手势
    if (self.openTopViewGestureRecognizer) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [self.topView addGestureRecognizer:pan];
    }
    self.topView.frame = CGRectMake(0, 0, kViewWidth, self.topViewHeight);
}
- (void)setupToolBarView {
    [self.backgroundScrollView addSubview:self.toolBarView];
    //添加pan手势
    if (self.openToolBarGestureRecognizer) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [self.toolBarView addGestureRecognizer:pan];
    }
    
    //存储点击事件
    __weak typeof (self)weakSelf = self;
    [self.toolBarView setClickOptionItemBlock:^(UIButton *itme, NSString *text, NSInteger index) {
        weakSelf.bottomScrollView.contentOffset = CGPointMake (self.bottomScrollViewArray.firstObject.frame.size.width * index,0);
        //回调点击事件
        _selectViewPage = index;
        if (weakSelf.clickToolBarViewBlock) {
            weakSelf.clickToolBarViewBlock(itme,weakSelf.bottomScrollViewArray[index],text,index);
        }
    }];
    
    self.toolBarView.frame = CGRectMake(0, kTopViewHeight, kViewWidth, self.toolBarViewHeight);
}
- (void)setupBottomView {
    if (!self.bottomScrollViewArray.count) return;
    
    //添加pan手势
    if (self.openBottomScrollViewGestureRecognizer) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [self.bottomScrollView addGestureRecognizer:pan];
    }
    [self.backgroundScrollView addSubview:self.bottomScrollView];
    self.bottomScrollView.frame = CGRectMake(0,kTopViewHeight + kToolBarViewHeight,kViewWidth,kViewHeight - kToolBarViewHeight - kTopViewHeight);
    
    CGFloat bottomContextSizeW = self.frame.size.width * self.bottomScrollViewArray.count * self.bottomScrollViewContentViewScale;
    CGFloat bottomContextSizeH = 0;
    self.bottomScrollView.contentSize = CGSizeMake(bottomContextSizeW, bottomContextSizeH);
    self.bottomScrollView.delegate = self;
    self.bottomScrollView.bounces = NO;
    self.bottomScrollView.pagingEnabled = self.pagingEnabled;
    self.bottomScrollView.showsHorizontalScrollIndicator = self.bottomViewHorizontalScrollIndicator;
    self.bottomScrollView.showsVerticalScrollIndicator = self.backgroundViewShowVerticalScrollIndicator;
    
    [self setupBottomScrollViewContentView];
}

//MARK:设置了bottomScrollView的subView的frame
- (void)setupBottomScrollViewContentView {

    __weak typeof (self)weakSelf = self;
    [self.bottomScrollViewArray enumerateObjectsUsingBlock:^(UIView * view, NSUInteger index, BOOL * _Nonnull stop) {
        
        CGFloat viewW = kViewWidth * weakSelf.bottomScrollViewContentViewScale;
        CGFloat viewH = weakSelf.bottomScrollView.frame.size.height;
        CGFloat viewX = viewW* index;
        view.frame = CGRectMake(viewX, 0, viewW, viewH);
        
        //MARK:如果是UIScrollview 那么就监听 contentOffset属性
        if ([view isKindOfClass:NSClassFromString(@"UIScrollView")] && self.topViewHeight) {
            UIScrollView *scrollView = (UIScrollView *)view;
            //添加contentOffset观察者
           [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self.observeScrollViewArray addObject:scrollView];
        }
        
        [weakSelf.bottomScrollView addSubview:view];
    }];
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
  
    if (scrollView == self.backgroundScrollView) {
            CGSize bottomSize = self.bottomScrollView.frame.size;
            CGFloat bottomViewH = self.frame.size.height - kTopViewHeight - kToolBarViewHeight + contentOffset.y - self.backgroundScrollView.frame.origin.y;
            CGFloat bottomViewW = bottomSize.width;
            
            CGPoint bottomViewOrigin = self.bottomScrollView.frame.origin;
            CGFloat bottomViewY = bottomViewOrigin.y;
            self.bottomScrollView.frame = CGRectMake(0, bottomViewY, bottomViewW, bottomViewH);
        [self changeBottomSubView];
        
        
//#warning mark -    由于计算频率过高会出现问题
//        dispatch_queue_t dispatch = dispatch_get_global_queue(0, 0);
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSMutableArray <NSValue *>*viewArrayM = [[NSMutableArray alloc]initWithCapacity:self.bottomScrollViewArray.count];
//            
//            __weak typeof (self)weakSelf = self;
//            [self.bottomScrollViewArray enumerateObjectsUsingBlock:^(UIView * view, NSUInteger index, BOOL * _Nonnull stop) {
//                CGPoint viewOrigin = view.frame.origin;
//                CGSize viewSize = view.frame.size;
//                CGFloat viewX = viewSize.width * index;
//                CGFloat viewY = viewOrigin.y;
//                CGFloat viewW = viewSize.width;
//                CGFloat viewH = weakSelf.bottomScrollView.frame.size.height;
//                CGRect frame = CGRectMake(viewX, viewY, viewW, viewH);
//                [viewArrayM addObject:[NSValue valueWithCGRect:frame]];
//            }];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.bottomScrollViewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull view, NSUInteger index, BOOL * _Nonnull stop) {
//                    view.frame = viewArrayM[index].CGRectValue;
//                }];
//            });
//        });
    }
    if (scrollView == self.bottomScrollView) {
        CGPoint offset = scrollView.contentOffset;
        //获取当前页
        NSInteger page = round(offset.x / (self.bottomScrollViewArray.firstObject.frame.size.width));
        if (self.toolBarView.selectItemIndex != page) {
            self.toolBarView.selectItemIndex = page;
            _selectViewPage = page;
            if(self.scrollBottomViewBlock){
                self.scrollBottomViewBlock(page,offset);
            }
        }
    }
}

- (void)changeBottomSubView {
    __weak typeof (self)weakSelf = self;
    [self.bottomScrollViewArray enumerateObjectsUsingBlock:^(UIView * view, NSUInteger index, BOOL * _Nonnull stop) {
        CGPoint viewOrigin = view.frame.origin;
        CGSize viewSize = view.frame.size;
        CGFloat viewX = viewSize.width * index;
        CGFloat viewY = viewOrigin.y;
        CGFloat viewW = viewSize.width;
        CGFloat viewH = weakSelf.bottomScrollView.frame.size.height;
        view.frame = CGRectMake(viewX, viewY, viewW, viewH);
    }];
}


#pragma mark - Obser
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)view change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        //判断是否为手拽
        UIScrollView *currentScrollView = (UIScrollView *)view;
        if (!currentScrollView.dragging && !currentScrollView.tracking && !currentScrollView.decelerating) {
            self.isScrollViewAccomplishScroll = YES;
            return;
        }
        self.isScrollViewAccomplishScroll = NO;
        
        //虽然能够调用 但contentoffset监听到的值 一直是第一个监听的scrollView的contentoffset
        //所以 自己取值
        NSInteger index = self.toolBarView.selectItemIndex;//第几个view
        UIScrollView *scrollView = (UIScrollView *)self.bottomScrollViewArray[index];
       
        CGPoint changeOffsetNew = scrollView.contentOffset;
        
        if (changeOffsetNew.y > self.topViewHeight * self.animaUpScale) {
            //如果scrollView的contentSize.height是小于scrollView的自身高度 + topViewHeight的那么就先偏移contentoffet
            if (scrollView.contentSize.height < self.backgroundScrollView.frame.size.height - kTopViewHeight - kToolBarViewHeight) {
                scrollView.bounces = NO;
                return;
            }else if (scrollView.contentSize.height < self.backgroundScrollView.frame.size.height - kTopViewHeight) {
                scrollView.bounces = NO;
                changeOffsetNew = CGPointMake(0, scrollView.contentSize.height - scrollView.frame.size.height);
                [UIView animateWithDuration:self.animaUpTime animations:^{
                [self observeBacgroundViewContentOffset: changeOffsetNew];
                }];
            }else if (scrollView.contentSize.height < self.backgroundScrollView.frame.size.height){
                scrollView.bounces = NO;
                [UIView animateWithDuration:self.animaUpTime animations:^{
                    [self observeBacgroundViewContentOffset: changeOffsetNew];
                }];
            }else {
                [UIView animateWithDuration:self.animaUpTime animations:^{
                    self.backgroundScrollView.contentOffset = CGPointMake(0, kTopViewHeight + self.backgroundScrollView.frame.origin.y);
                }];
            }
            return;
        }
        
        if (changeOffsetNew.y <= 0) {
            [UIView animateWithDuration:self.animaUpTime animations:^{
                self.backgroundScrollView.contentOffset = CGPointMake(0, self.backgroundScrollView.frame.origin.y);
            }];
            return;
        }
        [self observeBacgroundViewContentOffset: changeOffsetNew];
    }
}

- (void)observeBacgroundViewContentOffset: (CGPoint)changeOffset {
    
    //加一个backgroundScrollView 的y  （y表示超出的View顶部的距离 ）
    //防止backgroundScrollView 偏移向上太多
    if (changeOffset.y > kTopViewHeight + self.backgroundScrollView.frame.origin.y) {
        self.backgroundScrollView.contentOffset = CGPointMake(changeOffset.x, kTopViewHeight + self.backgroundScrollView.frame.origin.y);
        return;
    }
    //更新偏移量
    self.backgroundScrollView.contentOffset = CGPointMake(changeOffset.x, changeOffset.y + self.backgroundScrollView.frame.origin.y);
//    NSLog(@"---------%lf",changeOffset.y);
}
- (void)observeBottomViewFrameWithOrign: (CGPoint)orign {
    [self chengeBottomViewFrameWithOffset:orign];
}



#pragma mark - pan手势的响应事件
- (void)pan: (UIPanGestureRecognizer *)pan {
    
//    如果有scrollView在滚动那么会导致冲突所以在手势的时候 停止scrollview的滚动
//    if (!self.isScrollViewAccomplishScroll) {
//        return;
//    }
    
    //如果self.backgroundScrollView的位置大于0了  表示露出了后面的self 就return
    CGPoint panOffset = [pan translationInView:self];
    [pan setTranslation:CGPointZero inView:pan.view];
    
    if ((panOffset.y + self.backgroundScrollView.frame.origin.y < -kTopViewHeight)) {
        return;
    }
    
    if ((self.backgroundScrollView.frame.origin.y + panOffset.y > 0)) {
        return;
    }
    [self backgroundScrollViewFrameWithPanOffset:panOffset andAnimationTime:0];
}



#pragma mark - 改变bottomScrollView —— subView的frame
- (void)backgroundScrollViewFrameWithPanOffset: (CGPoint)offset andAnimationTime: (CGFloat)animationTime{
    if (animationTime) {
        [UIView animateWithDuration:self.animaDownTime animations:^{
            [self changeBackgrundScrollViewFrameAndSubViewFrame:offset];
        }];
        return;
    }
    [self changeBackgrundScrollViewFrameAndSubViewFrame:offset];
}
- (void)changeBackgrundScrollViewFrameAndSubViewFrame: (CGPoint)offset {
    //location
    CGPoint backgroundScrollViewLocation = self.backgroundScrollView.frame.origin;
    CGFloat backgroundScrollViewLocationY = backgroundScrollViewLocation.y + offset.y;
    CGFloat backgroundScrollViewLocationX = backgroundScrollViewLocation.x;
    
    //size
    CGSize backgroundScrollViewSize = self.backgroundScrollView.frame.size;
    CGFloat backgroundScrollViewSizeW = backgroundScrollViewSize.width;
    CGFloat backgroundScrollViewSizeH = backgroundScrollViewSize.height - offset.y;
    
    //backgroundScrollViewFrame
    self.backgroundScrollView.frame = CGRectMake(backgroundScrollViewLocationX,backgroundScrollViewLocationY,backgroundScrollViewSizeW,backgroundScrollViewSizeH);
    
    [self chengeBottomViewFrameWithOffset:offset];
}
- (void)chengeBottomViewFrameWithOffset: (CGPoint)offset{
    
    CGFloat bottomScrollViewX = self.bottomScrollView.frame.origin.x;
    CGFloat bottomScrollViewY = self.bottomScrollView.frame.origin.y;

    CGFloat bottomScrollViewW = self.backgroundScrollView.frame.size.width;
    CGFloat buttomScrollViewH = self.backgroundScrollView.frame.size.height - kTopViewHeight - kToolBarViewHeight;
    self.bottomScrollView.frame = CGRectMake(bottomScrollViewX, bottomScrollViewY, bottomScrollViewW, buttomScrollViewH);
    //NSLog(@"%@",[NSValue valueWithCGRect:self.bottomScrollView.frame]);
    
    __weak typeof (self)weakSelf = self;
    [_bottomScrollViewArray enumerateObjectsUsingBlock:^(UIView *  view, NSUInteger index, BOOL *  stop) {
        CGFloat viewW = kViewWidth * weakSelf.bottomScrollViewContentViewScale;
        CGFloat viewH = weakSelf.bottomScrollView.frame.size.height;
        CGFloat viewX = viewW* index;
        view.frame = CGRectMake(viewX, 0, viewW,viewH);
    }];
}



#pragma mark - 手势识别 解决手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - 获取subView类对象
- (NSArray <UIView *>*)gitSubViewAccordingToSubViewName: (NSArray <NSString *>*)subViewNameArray {
    NSMutableArray *subViewArrayM = [[NSMutableArray alloc]initWithCapacity:subViewNameArray.count];
    
    [subViewNameArray enumerateObjectsUsingBlock:^(NSString * _Nonnull subViewNameStr, NSUInteger idx, BOOL * _Nonnull stop) {
        Class obj = NSClassFromString(subViewNameStr);
        UIView *view = [[obj alloc]init];
        [subViewArrayM addObject:view];
        [self addSubview:view];
    }];
    return subViewArrayM.copy;
}


#pragma mark - 注销观察者
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentOffset"];
    [self removeObserver:self forKeyPath:@"frame"];
    NSLog(@"✅%@销毁",[self class] );
}



@end




//MAKR: ------------------------- ~ readMe ~ ----------------------------
/*
 一、 首先层次结构：
 1. self(view)里面包括：（backgroundScrollView）
 2. backgroundScrollView里面包括：（topView 和toolBarView 还有bottomView）
 3. bottomView里面包括：（外部传进来的view集合）
 
 
二、 实现技术：
 
    1.topView添加pan手势：
     （1.1 调用方法：） -(void)backgroundScrollViewFrameWithPanOffset: (CGPoint)offset andIsAnima: (BOOL)anima；
 
     （1.2实现：） 实现了backgroundScrollView的offset设置
     （1.3注意：）（这里设置的是contentOffset 其坐标没有变，改变了bottomView及子控件的大小）
    
 
 
    2.对bottomView的subView 遍历判断是否为scrollView（或子类） 如果是，添加监听者
     （1.1 调用方法：）- (void)observeBacgroundViewContentOffset: (CGPoint)changeOffset;
     （1.2 实现：）实现了backgroundScrollView的offset设置
     （1.3 注意：）（这里设置的是contentOffset 其坐标没有变，改变了bottomView及子控件的大小）
         （注意：） 这里面做了防止backgroundScrollView 偏移超出范围的判断
 */

