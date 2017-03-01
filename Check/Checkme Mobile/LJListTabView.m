//
//  LJListTabView.m
//  xuanzhuanDemo
//
//  Created by Viatom on 15/10/16.
//  Copyright (c) 2015年 YilingOranization. All rights reserved.
//

#import "LJListTabView.h"

@implementation LJListTabView
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
        self.rowHeight = 120;
        
        //计算内填充的大小
        _edge = (kScreenWidth - self.rowHeight) / 2.0;
        [self setContentInset:UIEdgeInsetsMake(_edge, 0, _edge, 0)];
        
        //设置滑动动画的速度
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        
        //初始化当前选中的单元格
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
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
    SlideDeleteCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (cell == nil) {
        cell = [[SlideDeleteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
        cell.delegate = self;
        //设置单元格的背景
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        
        //取消选中样式
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //5.顺时针旋转单元格的内容视图
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        //创建父视图
        UIView *superView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.rowHeight, self.height)];
        //tag
        superView.tag = 101;
        superView.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:superView];
     
        
        //创建图片视图
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.rowHeight * .05, 5, self.rowHeight *.9, self.height - 10)];
        //tag
        imageView.tag = 2014;
        imageView.backgroundColor = [UIColor clearColor];
        [superView addSubview:imageView];
        
        
        
        
        UIImageView *playView = [[UIImageView alloc] initWithFrame:CGRectMake((superView.width - 35) / 2.0, 30, 35, 35)];
        playView.contentMode = UIViewContentModeScaleAspectFit;
        playView.image = [UIImage imageNamed:@"play"];
        [superView addSubview:playView];
        
        
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 60 , superView.width - 20, superView.height - 60)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont boldSystemFontOfSize:14];
        timeLabel.numberOfLines = 0;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.tag = 2015;
        [superView addSubview:timeLabel];
        
        
    }
    //
    UIView *superView = (UIView *)[cell.contentView viewWithTag:101];
    //获取图片视图
    UIImageView *imageView = (UIImageView *)[superView viewWithTag:2014];

    imageView.image = [UIImage imageNamed:@"xindian"];
    
    //标题
    UILabel *timeLabel = (UILabel *)[superView viewWithTag:2015];
    Notice *notice = self.dataList[indexPath.row];
    timeLabel.text = [NSString stringWithFormat:@"%@",notice.NameString];
    return cell;
}

//单元格点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //判断点击是否是当前显示的
    if(self.selectedIndexPath.row == indexPath.row && self.selectedIndexPath.section == indexPath.section)
    {
        UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"提示" message:@"亲,要播放当前数据嘛~~" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        aler.tag = 201;
        [aler show];
        
    } else {
        //记录当前选中的单元格
        self.selectedIndexPath = indexPath;
        //该单元格滑动到指定位置
        [tableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}

-(void)slideToDeleteCell:(SlideDeleteCell *)slideDeleteCell{
  
    _deletedIndexPath = [self indexPathForCell:slideDeleteCell];
   
//    if(_deletedIndexPath.row ==  self.selectedIndexPath.row && _deletedIndexPath.section == _deletedIndexPath.section)
//    {
//
//    } else {
//       
//        
//    }
   
    self.selectedIndexPath = _deletedIndexPath;
    //该单元格滑动到指定位置
    [self scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

    UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"提示" message:@"亲,是否要删除该视频~~" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    aler.tag = 200;
    [aler show];
   
    
}

#pragma mark ------- UIAlertView  Delegate --------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 201) {
        if (buttonIndex == 1) {
            [_LJListdelegate gotoPlayMoviceselectedIndexPath:self.selectedIndexPath];
            
        }
    }
    
    if (alertView.tag == 200) {
        if (buttonIndex == 1) {
           
            NSMutableArray *new  = [NSMutableArray new];
            [new addObjectsFromArray:self.dataList];
            [new removeObjectAtIndex:_deletedIndexPath.row];
            self.dataList = new;
            [self deleteRowsAtIndexPaths:@[_deletedIndexPath] withRowAnimation:UITableViewRowAnimationRight];
            //从数据库删除
            NSArray *array = [Notice allDbObjects];
            Notice *notice = array[(array.count - 1 - _deletedIndexPath.row)];
            [notice removeFromDb];
        }
    }

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

#pragma mark - 缩放效果

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
     //    NSLog(@"y:%f",scrollView.contentOffset.y);

     //获取当前屏幕所有现实的单元格索引的集合
     NSArray *indexPaths = [self indexPathsForVisibleRows];
     for (NSIndexPath *indexPath in indexPaths) {
     
     //计算该单元格在中心位置显示的时候,当前表示图的偏移量
     double cell_center = indexPath.row * self.rowHeight - _edge;
     
     //当前表视图的偏移量
     double now_contentOfSet_y = scrollView.contentOffset.y;
     
     //获取当前单元格距离中心位置有多少距离
      double lenght = fabs(cell_center - now_contentOfSet_y);
    //
    //   NSLog(@"lenght:%f",lenght);
      //根据距离设置一个缩放比例,和距离成反比 0.9~ 0.7 (8 ~ 10)
       float scale = (10 - lenght / 380) * .1;
       float scale1 =(10 - lenght / 180) * .1;

     //获取该单元格
     SlideDeleteCell *cell = (SlideDeleteCell *)[self cellForRowAtIndexPath:indexPath];

     //回去里面的图片
     UIView *superView = (UIView *)[cell.contentView viewWithTag:101];


     //进行缩放
     superView.transform = CGAffineTransformMakeScale(scale , scale1);
 
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
