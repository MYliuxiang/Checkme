//
//  PosterHeaderTableView.m
//  MyMovie
//
//  Created by zsm on 14-8-18.
//  Copyright (c) 2014年 zsm. All rights reserved.
//

#import "PosterHeaderTableView.h"
@implementation PosterHeaderTableView

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
        self.rowHeight = 140;
        
        //计算内填充的大小
        _edge = (kScreenWidth - self.rowHeight) / 2.0;
        [self setContentInset:UIEdgeInsetsMake(_edge, 0, _edge, 0)];
        
        //设置滑动动画的速度
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        
        //初始化当前选中的单元格
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
        
        //创建图片视图
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.rowHeight * .05, 0, self.rowHeight *.9, self.height)];
        //tag
        imageView.tag = 2014;
        imageView.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:imageView];
        
        
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.height - 35 , self.rowHeight - 20, 35)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont boldSystemFontOfSize:13];
        timeLabel.numberOfLines = 0;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.tag = 2015;
        [cell.contentView addSubview:timeLabel];

    }
    //获取图片视图
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:2014];
    //获取当前单元格对应的数据原型
    STDImagetice *imagetice = self.dataList[indexPath.row];
    UIImage *image = [UIImage imageWithData: imagetice.data];
    imageView.image = image;
    
    //标题
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:2015];
    timeLabel.text = [NSString stringWithFormat:@"%@",imagetice.EnddateString];

    
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


#pragma mark - UIScrollView Delegate
//手指离开的时候调用的方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //如果没有减速效果的时候
    if (!decelerate) {
        //判断那一个单元格在中心位置上,就让该单元格滑动到中心位置
        [self _scrollviewDidEndScroll:scrollView];
    }
}

//减速效果停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //判断那一个单元格在中心位置上,就让该单元格滑动到中心位置
    [self _scrollviewDidEndScroll:scrollView];
}

//判断那一个单元格在中心位置上,就让该单元格滑动到中心位置
- (void)_scrollviewDidEndScroll:(UIScrollView *)scrollView
{
    //通过这个算法计算当前中心的单元格
    NSInteger rowIndex = (scrollView.contentOffset.y +_edge + self.rowHeight * .5)  / self.rowHeight;
    self.selectedIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    [self scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

@end
