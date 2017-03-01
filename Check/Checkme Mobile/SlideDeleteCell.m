//
//  SlideDeleteCell.m
//  RHSlideDeleteTableViewCell
//
//  Created by london on 14-2-21.
//  Copyright (c) 2014年 Robin_Huang. All rights reserved.
//

#import "SlideDeleteCell.h"

#define kRotationRadian  90.0/360.0
#define kVelocity        80

@interface SlideDeleteCell()

@property(assign, nonatomic) CGPoint currentPoint;
@property(assign, nonatomic) CGPoint previousPoint;
@property(strong, nonatomic) UILongPressGestureRecognizer *LongGestureRecognizer;
@property(assign, nonatomic) float offsetRate;

@end

@implementation SlideDeleteCell
@synthesize delegate;

#pragma mark - Initialization -

- (id)init
{
    if (self = [super init])
	{
        [self addPanGestureRecognizer];
    }
	
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
        [self addPanGestureRecognizer];
    }
	
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addPanGestureRecognizer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self addPanGestureRecognizer];
	}
	
	return self;
}

-(void)addPanGestureRecognizer{
    _LongGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(slideToDelete:)];
    _LongGestureRecognizer.minimumPressDuration = 1.0;
    [self addGestureRecognizer:_LongGestureRecognizer];
    
}

#pragma mark UIGestureRecognizerDelegate------------------------------------------------

-(void)slideToDelete:(UILongPressGestureRecognizer *)gesture{
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        if ([delegate respondsToSelector:@selector(slideToDeleteCell:)]) {
            [delegate slideToDeleteCell:self];
        }
    }
    
   
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
        
}

@end
