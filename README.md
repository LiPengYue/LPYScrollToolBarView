![scrollToolBarView.gif](http://upload-images.jianshu.io/upload_images/4185621-24aec367acb951dc.gif?imageMogr2/auto-orient/strip)


>![关注简书](http://www.jianshu.com/p/880d5e7969ca)
#一、简介
这个工具写了很久，一直不满意，换了n种方法，最后毛瑟顿开，用最平常的知识解决了问题。所以很简单，但很巧妙。
> 1. 适用结构： 
`1. 顶部有一个topView`
`2. 中间有个选项栏（toolBarView）`
`3. 底部有scrollVIew的集合（UITableView，UICollectionView）`
>2. 效果：
`1. 随着底部的scrollView的滚动，topView与toolBarView也跟着上下滚动。`
`2. toolBarView的到顶部的时候悬停`
>3. 主要解决的问题：
`1. 解决了根据底部scrollView的不同contentOffset设置topView与toolBarView的高度问题`
`2. 解决了中间toolBar悬停的问题`
`3. 解决了底部scrollView左右滑动的问题`

#二、 知识点
1. [scrollView的一些知识，看这里](http://www.jianshu.com/p/eec5cff64024)
2. [关于toolBarView的封装，看这里](http://www.jianshu.com/p/327d2e7fd19b)
3. [CoreGraphics的知识，看这里]()

#三、工具结构
整体由最低层的`ScrollView`、`topView`、`midToolBarView`、`bottomScrollView`、还有`bottomScrollViews`组成
**1. 主要的包含关系**
>1. 最底层scrollVIew
`1.在他的上面有topView，midToolBarView，bottomScrollView，bottomScrollViewArray`
`1. 这样的话就可以做到让bottomViews，midToolBarView，topView，一起上下滚动，只修改最低层的scrollView的contentOffset就可以了`
>2. 顶部的topView
`为了扩展性，这个顶部的topView是由外部传进来`
>3. 中间的toolBarView
`1. 这个是选项栏，也就是点击相应的按钮，底部的BottomScrollView就会相应相应的界面`
`2. toolBarView的点击事件有传出到外部`
`3.  toolBarView的titleArray应该与BottomScrollView中的bottomScrollViewArray数目一致`
`4. 点击滑动到相应的ScrollView界面`
`5. 与下部的BottomScrollView滑动不会产生冲突`
>4. 底部的BottomScrollView
`1. 主要是承接bottomScrollViewArray，让他们依次排列，并且可以左右滚动`
`2. 设置了分页，每次到新的页面都会向外发送index和ScrollView消息`
`3. 对数组长度进行了判断，避免了数组越界造成的崩溃`
>5. bottomScrollViewArray
`1. 这个是外部传入的scrollView 的数组`
`2. 内部监听了bottomScrollViewArray元素的contentOffset，对self.contentOffset进行设置，达到联动效果`

#四、遇到的问题
**1. 当底部有多个scrollView或者多个view的时候，解决底部scrollView的contentOffset不一致造成的self.contentOffset的滑动突兀的问题**
造成这个问题的根本原因是:
>1. 我在外部传入BottomScrollViewArray的时候会先判断其是否为scrollView，**`如果是scrollView，那么监听了scrollView的contentOffset，并根据scrollView的contentOffset，改变self.contentOffset`**
>2. 在监听的会调函数中，根据监听到的ScrollView的滚动的contentOffset改变self.contentOffset
>3. 如果，bottomScrollViewArray中有A、B两个scrollView做下面操作
 `1. A滚动30的距离（这时候self.contentOffset.y跟随A变成了30）`
`2. 现在切换到了B，这时候就会出现问题`
`3. 因为B的contentOffset.y为0，而self.contentOffset为30，当你在滑动B的时候，B的contentOffset发生改变，那么将对self.contentOffset重新赋值，这时候，B的contentOffset.y为0，而self.contentOffset.y为30,则self.contentOffset会直接变成0`

**解决方案：**
>1. 添加了一个OffsetY变量。
在将要切换的底部的scrollView的时候对A与B进行contentOffset.y差值计算。
在B滑动的时候把差值也算入到self.contentOffset中。
在滑动到顶部，或者底部的时候，对offsetY进行清零
`但是还是有缺陷，比如A的contentOffset.y 为0，而self.contentOffset.y已经到最大，那么切换到A，向下拉，也会有self直接掉下来的突兀感`



**代码：**
````
 ///布局bottomScrollView的subView （把subView添加到了bottomScrollViewView里面）
    private func setupBottomScrollViewSubView(_ contentOffsetY: CGFloat) {
        for index: NSInteger in 0 ..< self.bottomViewArray.count {
            //布局subview
            let view: UIView = self.bottomViewArray[index]
            self.bottomScrollView.addSubview(view)
            view.frame = CGRect(x: kToolBarScrollViewW * CGFloat(index), y:0, width: kToolBarScrollViewW, height: kBottomScrollViewH + contentOffsetY)
            //如果要是是ScrollView的子类那么监听contentOffset
            if view is UIScrollView {
                let scrollView: UIScrollView = view as! UIScrollView
                scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            }
        }
    }

 ///通知的方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
//            print(change?[NSKeyValueChangeKey.newKey] ?? "----- 没有纸")
            let scrollView: UIScrollView = object as! UIScrollView
            //获取偏移量
            let newValue: CGPoint = change?[NSKeyValueChangeKey.newKey] as! CGPoint
            self.newValue = newValue;
            //改变scrollView偏移的位置
            if scrollView.contentOffset.y <= 0{
                if newValue.y < 0 {
                    self.offset = 0
                }
                self.contentOffset = CGPoint(x: 0, y: 0)
            }
            if scrollView.contentOffset.y >= self.kTopViewH {
                if newValue.y > self.kTopViewH {
                    self.offset = 0
                }  
                self.contentOffset = CGPoint(x: 0, y: self.kTopViewH)
            }
//            let isScrollBottom = Int(scrollView.contentSize.height - self.contentOffset.y) <= Int(scrollView.frame.size.height);
            if scrollView.contentSize.height <= scrollView.frame.size.height + kTopViewH {   
                let insertY = scrollView.frame.size.height + kTopViewH - scrollView.contentSize.height   
                scrollView.contentInset = UIEdgeInsetsMake(0, 0, insertY, 0)
            }else{
                scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            }
            self.contentOffset = CGPoint(x: 0, y: newValue.y + self.offset)
        }
    }
````

**2. 当前显示的scrollView的contentSize滑动不到顶部，底部的scrollView就会显示不全**
解决方法：
在滚动的时候判断，当前的scrollView的滑动范围，是否足以让self滑动到顶部
```
 if scrollView.contentSize.height <= scrollView.frame.size.height + kTopViewH {
                
                let insertY = scrollView.frame.size.height + kTopViewH - scrollView.contentSize.height
                
                scrollView.contentInset = UIEdgeInsetsMake(0, 0, insertY, 0)
            }else{
                scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            }
            
            self.contentOffset = CGPoint(x: 0, y: newValue.y + self.offset)
        }
````
