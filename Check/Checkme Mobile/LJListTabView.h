//
//  LJListTabView.h
//  xuanzhuanDemo
//
//  Created by Viatom on 15/10/16.
//  Copyright (c) 2015年 YilingOranization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideDeleteCell.h"
@protocol LJListPlayDelegate

- (void)gotoPlayMoviceselectedIndexPath:(NSIndexPath *)selected;

@end

@interface LJListTabView : UITableView<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,SlideDeleteCellDelegate>
{
    double _edge;   //内填充的大小
}
@property (nonatomic,retain) NSArray *dataList;
@property (nonatomic,retain) NSIndexPath *selectedIndexPath;
@property (nonatomic,retain) NSIndexPath *deletedIndexPath;
@property (nonatomic,assign) id<LJListPlayDelegate>LJListdelegate;
@end
