//
//  PosterBodyTableView.h
//  MyMovie
//
//  Created by zsm on 14-8-18.
//  Copyright (c) 2014年 zsm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PosterBodyTableView : UITableView<UITableViewDataSource,UITableViewDelegate>
{
    double _edge;   //内填充的大小
}
@property (nonatomic,retain)NSArray *dataList;
@property (nonatomic,retain)NSIndexPath *selectedIndexPath;
//@property (nonatomic) int imageSetle;
//@property (nonatomic,strong)NSArray *imageArray;
@end
