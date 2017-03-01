//
//  HdScrollView.h
//  ScrollView
//
//  Created by Hu Di on 13-10-11.
//  Copyright (c) 2013年 Sanji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HdPageControl.h"
@protocol HDScrollviewDelegate <NSObject>
-(void)TapView:(int)index;
@end

@interface HDScrollview : UIScrollView<UIScrollViewDelegate>

@property (nonatomic,strong) HdPageControl *pagecontrol;
@property (nonatomic,assign) NSInteger currentPageIndex;
@property (assign,nonatomic) id<HDScrollviewDelegate> HDdelegate;
/**
 *	@brief	不循环
 */
-(id)initWithFrame:(CGRect)frame withImageView:(NSMutableArray *)imageview;

/**
 *	@brief	不循环,普通uiview
 */
-(id)initWithFrame:(CGRect)frame withUIView:(NSMutableArray *)uiViewArr;

/**
 *	@brief	循环滚动
 */
-(id)initLoopScrollWithFrame:(CGRect)frame withImageView:(NSMutableArray *)imageview;
-(void)HDscrollViewDidScroll;
-(void)HDscrollViewDidEndDecelerating;

-(void)pageTurn:(UIPageControl *)sender; //joe add

@end

@interface UIImageView (CopyImageview)<NSCoding>
@end


