//
//  PosterBodyTableView.m
//  MyMovie
//
//  Created by zsm on 14-8-18.
//  Copyright (c) 2014年 zsm. All rights reserved.
//

#import "PosterBodyTableView.h"
//#import "BodyView.h"

@implementation PosterBodyTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code
        //实现代理代理对象
        self.delegate = self;
        self.dataSource = self;
        
        //设置背景为透明的
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        
        //隐藏单元格分割线
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //1.逆时针旋转90度
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
        
        //2.重新设置frame
        self.frame = frame;
        
        //3.滑动指示器
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        //4.单元格的高度
        self.rowHeight = 600;
        
        //计算内填充的大小
        _edge = (kScreenWidth - self.rowHeight) / 2.0;
        [self setContentInset:UIEdgeInsetsMake(_edge, 0, _edge, 0)];
        
        //设置滑动动画的速度
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        
//        //初始化当前选中的单元格
//        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"postBodyCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        //设置单元格的背景
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        
        //取消选中样式
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //5.顺时针旋转单元格的内容视图
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        //------------------子类化单元格------------
        //1.创建父视图
        UIView *superView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.rowHeight, self.height- 150)];
        //tag
        superView.tag = 101;
        superView.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:superView];
     
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [superView addGestureRecognizer:tap];
        
        
        
//        //2.创建电影的详情视图
//        BodyView *bodyView = [[[NSBundle mainBundle] loadNibNamed:@"BodyView" owner:self options:nil] lastObject];
//        bodyView.frame = superView.bounds;
//        //tag
//        bodyView.tag = 102;
//        [superView addSubview:bodyView];
        
        
        //3.创建图片视图
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:superView.bounds];
        //tag
        imageView.tag = 103;
        imageView.backgroundColor = [UIColor redColor];
        [superView addSubview:imageView];
      
        
        
    }
    
    
    //获取当前单元格对应的数据原型
    STDImagetice *imagetice = self.dataList[indexPath.row];
   
    UIImage *image = [UIImage imageWithData: imagetice.data];
    

    //1.获取图片视图
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:103];
    imageView.image = image;
    
    //判断图片视图是否在上面,如果不在上面我们就交换
    UIView *superView = [cell.contentView viewWithTag:101];
//    [superView addSubview:imageView];
    if (![[superView.subviews lastObject] isMemberOfClass:[UIImageView class]]) {
        [superView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    }
    
//    //2.给图片详情视图赋值
//    BodyView *bodyView = (BodyView *)[cell.contentView viewWithTag:102];
//    bodyView.model = model;
    return cell;
}

//单元格点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //记录当前选中的单元格
    self.selectedIndexPath = indexPath;
    
    //该单元格滑动到指定位置
    [tableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //手动的调用一下滑动的协议方法
    [self scrollViewDidScroll:self];
}


#pragma mark - UIScrollView Delegate
//手指离开屏幕时候调用的
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //velocity :加速状态,可以根据它的值判断滑动方向
    NSLog(@"%f",velocity.y);
    
//    targetContentOffset->y = 300;
    
    //1.获取手足滑动之前表示图的偏移量
    double contentOfSet_y = self.selectedIndexPath.row * self.rowHeight - _edge;
    
    //2.获取手指离开时表示图的偏移量
    double touchEnd_y = scrollView.contentOffset.y;
    
    //3.根据原始的位置和手指离开的位置判断滑动到那一个单元格
    if (velocity.y >= .7 || touchEnd_y - contentOfSet_y >= 70) {
        //-----------向左滑动,要现实右边的视图---------------
        //记录当前选中的单元格
        //判断当前的单元格不是最有一个,执行if里面的操作
        if (self.selectedIndexPath.row < self.dataList.count - 1) {
            self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row + 1 inSection:0];
        }
        
        targetContentOffset ->y = self.selectedIndexPath.row * self.rowHeight - _edge;
    } else if (velocity.y <= -0.7 || touchEnd_y - contentOfSet_y <= -70) {
        //-----------向右滑动,要现实左侧的视图---------------
        //记录当前选中的单元格
        //但当前单元格不是第一个执行if里的操作
        if (self.selectedIndexPath.row > 0) {
            self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row - 1 inSection:0];
        }
        
        targetContentOffset ->y = self.selectedIndexPath.row * self.rowHeight - _edge;
    } else {
        targetContentOffset ->y = self.selectedIndexPath.row * self.rowHeight - _edge;
    }
    
}

#pragma mark - 缩放效果
/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"y:%f",scrollView.contentOffset.y);
    NSLog(@"----------------------");
    //获取当前屏幕所有现实的单元格索引的集合
    NSArray *indexPaths = [self indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPaths) {
       
//        NSLog(@"indexPath:%@",indexPath);
        //计算该单元格在中心位置显示的时候,当前表示图的偏移量
        double cell_center = indexPath.row * self.rowHeight - _edge;
        
        //当前表视图的偏移量
        double now_contentOfSet_y = scrollView.contentOffset.y;
        
        //获取当前单元格距离中心位置有多少距离
        double lenght = abs(cell_center - now_contentOfSet_y);
        
        NSLog(@"lenght:%f",lenght);
        //根据距离设置一个缩放比例,和距离成反比 0.9~ 0.7 (8 ~ 10)
        float scale = (10 - lenght / 135) * .1;
        
        //获取该单元格
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        //回去里面的图片
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:2014];
        //进行缩放
        imageView.transform = CGAffineTransformMakeScale(scale, scale);
        
    }
}
 */

#pragma mark - 旋转效果
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSLog(@"y:%f",scrollView.contentOffset.y);
    NSLog(@"----------------------");
    //获取当前屏幕所有现实的单元格索引的集合
    NSArray *indexPaths = [self indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPaths) {
        
        //        NSLog(@"indexPath:%@",indexPath);
        //计算该单元格在中心位置显示的时候,当前表示图的偏移量
        double cell_center = indexPath.row * self.rowHeight - _edge;
        
        //当前表视图的偏移量
        double now_contentOfSet_y = scrollView.contentOffset.y;
        

        //根据距离设置一个缩放比例,和距离成反比 0.9~ 0.7 (8 ~ 10)
        // 270 ~ 0  0 ~ 0.2
        float hd = (now_contentOfSet_y - cell_center) / 2000;
        
        //获取该单元格
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        //回去里面的图片
        UIView *superView = [cell.contentView viewWithTag:101];
        
        //CATransform3D
        CATransform3D transform3d = CATransform3DMakeScale(1.2, 1.2, 1.2);
        //设置远近的效果
        transform3d.m34 = -1.2/200.f;
        transform3d = CATransform3DRotate(transform3d, hd, 0.0f, 1.0f, 0.0f);
        //把旋转效果设置给imageView
        [superView.layer setTransform:transform3d];
        
        
    }
}


#pragma mark - UITap Action
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    
    //1.获取我们点击单元格的索引位置
    CGPoint point = [tap locationInView:self];
    NSInteger rowIndex = point.y / self.rowHeight;
    
    //判断当前点击的视图是否在中间位置
    if (self.selectedIndexPath.row == rowIndex) {
        //定义旋转方向(默认向左)
        UIViewAnimationTransition transition = UIViewAnimationTransitionFlipFromRight;
        //如果上面的视图是UIImageView ,我们就向右翻转
        if ([[tap.view.subviews lastObject] isKindOfClass:[UIImageView class]]) {
            transition = UIViewAnimationTransitionFlipFromLeft;
        }
        
        //设置动画
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.35];
        //设置翻转效果
        [UIView setAnimationTransition:transition forView:tap.view cache:YES];
        
        [tap.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
        //提交动画
        [UIView commitAnimations];

    } else {
        //记录当前选中单元格
        self.selectedIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
        //滑动到指定位置
        [self scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}



@end
