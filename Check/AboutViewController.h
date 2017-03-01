//
//  AboutViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14/10/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"


@interface AboutViewController : UIViewController

@property(nonatomic,retain) IBOutlet UILabel* lblVersion;

@property (weak, nonatomic) IBOutlet UIImageView *appIconImg;

@property (weak, nonatomic) IBOutlet UILabel *appName;

-(IBAction)showLeftMenu:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *lab1;

@property (strong, nonatomic) IBOutlet UILabel *lab2;


@property (strong, nonatomic) IBOutlet UILabel *lab3;

@property (strong, nonatomic) IBOutlet UILabel *lab4;


@property (strong, nonatomic) IBOutlet UILabel *lab_1;


@property (strong, nonatomic) IBOutlet UILabel *lab_2;

@property (strong, nonatomic) IBOutlet UILabel *lab_3;
@property (strong, nonatomic) IBOutlet UILabel *lab_4;

@property (strong, nonatomic) IBOutlet UILabel *lab_5;



@end
