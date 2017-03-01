//
//  PosterHeaderTableView.h
//  MyMovie
//
//  Created by zsm on 14-8-18.
//  Copyright (c) 2014年 zsm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PosterHeaderTableView : UITableView<UITableViewDataSource,UITableViewDelegate>
{
    double _edge;   //内填充的大小
}
@property (nonatomic,retain)NSArray *dataList;
@property (nonatomic,retain)NSIndexPath *selectedIndexPath;

@end
