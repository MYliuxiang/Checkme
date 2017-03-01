//
//  LeftMenuViewController.m
//  REFrostedViewControllerStoryboards
//
//  Created by Roman Efimov on 10/9/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "DailyCheckViewController.h"
#import "ECGViewController.h"
#import "SPO2ViewController.h"
#import "TempViewController.h"
#import "SLMViewController.h"
#import "PedViewController.h"
#import "RelaxMeViewController.h"
#import "LeftMenuCell.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "AboutCheckmeViewController.h"
#import "Colors.h"
#import "UserList.h"

#import "NavigationViewController.h"
#import "MobClick.h"

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController
{
    double viewWidth;
    double viewHeight;
    double imgWidth;
    double imgHeight;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"LeftPage"];
    
    [self initHeader];
    [self.tableView reloadData];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"LeftPage"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initParameters];
    [self initHeader];
    [self initTableView];
}

- (void) initParameters
{
    viewWidth = CUR_SCREEN_W;//设置宽度为屏幕宽度
    viewHeight = 70;
    imgWidth = 170;
    imgHeight = 30;
}

-(void)initHeader
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
//    view.backgroundColor = DEFAULT_BLUE;
    view.backgroundColor = [UIColor whiteColor];
    //放在view的2/3处
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((viewWidth-50)/2-imgWidth/2.0, viewHeight*(2.0/3.0) - imgHeight/2.0, imgWidth, imgHeight)];
    imageView.image = [UIImage imageNamed:@"BM logo 2.jpg"];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
    if ([curCountry isEqualToString:@"JP"] && [curLanguage isEqualToString:@"ja"]) {   //如果是日本的
        imageView.image = [UIImage imageNamed:@"BM logo 2.jpg"];
    }
    if (isThomson == YES) {  //如果是法国定制版
        imageView.image = [UIImage imageNamed:@"BM logo 2.jpg"];
    }
    if (isSemacare == YES) {
        imageView.image = [UIImage imageNamed:@"BM logo 2.jpg"];
    }
    
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    imageView.layer.shouldRasterize = YES;
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = [UIColor clearColor];
    [view addSubview:imageView];
    [self.view addSubview:view];
}

- (void) initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, viewHeight, CUR_SCREEN_W, CUR_SCREEN_H-(viewHeight)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = Colol_cellbg;//设置一个背景色
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = DEFAULT_BLUE;//设置一个背景色
    [self.view addSubview:self.tableView];//将table表视图加入到当前控制器的视图中去
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        UIImageView* imgView = [[UIImageView alloc]initWithFrame:view.frame];
        [imgView setImage:[UIImage imageNamed:@"ljleft_menu_section_header_bkg.png"]];
//        imgView.backgroundColor = [MyColor colorWithHexString:@"cfcdcd"];
        [view addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
        label.text = DTLocalizedString(@"Data Review", nil);
        label.textColor = Colol_labnum;
        label.font = [UIFont boldSystemFontOfSize:15];
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        [view addSubview:label];
        
        return view;

    }else{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        UIImageView* imgView = [[UIImageView alloc]initWithFrame:view.frame];
        [imgView setImage:[UIImage imageNamed:@"ljleft_menu_section_header_bkg.png"]];
//      imgView.backgroundColor = [MyColor colorWithHexString:@"cfcdcd"];
        [view addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
        label.text = DTLocalizedString(@"More", nil);
        label.font = [UIFont boldSystemFontOfSize:15];
        label.textColor = Colol_labnum;
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        [view addSubview:label];
        
        return view;
    }
}

//设置行高...
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 34;
    
    return 34;
}


//设置tableview 表视图上面cell单元格点击事件(根据不同的cell单元格来显示加载不同的控制器)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //每次点击后 滚动到最顶端
    NSIndexPath *ind = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableView scrollToRowAtIndexPath:ind atScrollPosition:UITableViewScrollPositionBottom animated:NO];

    NavigationViewController *navigationController = (NavigationViewController *)self.mm_drawerController.centerViewController;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            DailyCheckViewController *dailyCheckViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"dailyCheckViewController"];
            navigationController.viewControllers = @[dailyCheckViewController];
        }else if (indexPath.row == 1) {
            ECGViewController *ecgViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ecgViewController"];
            navigationController.viewControllers = @[ecgViewController];
        }else if (indexPath.row == 2) {
            SPO2ViewController *spo2ViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"spo2ViewController"];
            navigationController.viewControllers = @[spo2ViewController];
        }else if (indexPath.row ==3) {
            TempViewController *tempViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tempViewController"];
            navigationController.viewControllers = @[tempViewController];
        }else if (indexPath.row == 4) {
//            SLMViewController *slmViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"slmViewController"];
//            navigationController.viewControllers = @[slmViewController];
             RelaxMeViewController *slmViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"relaxMeViewController"];
             navigationController.viewControllers = @[slmViewController];
        }else if (![UserList instance].isSpotCheck && indexPath.row == 5) {
            PedViewController *pedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pedViewController"];
            navigationController.viewControllers = @[pedViewController];
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 1) {
            AboutCheckmeViewController* aboutCheckmeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutCheckmeViewController"];
            navigationController.viewControllers = @[aboutCheckmeViewController];
        }else if (indexPath.row == 2) {
            AboutViewController* aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutViewController"];
            navigationController.viewControllers = @[aboutViewController];
        }else if (indexPath.row == 0) {
            SettingsViewController* settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsViewController"];
            navigationController.viewControllers = @[settingsViewController];
        }
    }
    
    [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex==0) {
        return [UserList instance].isSpotCheck?5:6;//判断是否显示多少。。。
    }else
        return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        if (indexPath.section == 0) {
             NSMutableArray *imgNames = [@[@"ljbodycheck_icon.png",@"ljecg_l.png",@"ljspo2_l.png",@"ljtemp_l.png",@"ljrelax_me_icons.png",@"ljstep_l.png"] mutableCopy];
            NSMutableArray *titles = [@[DTLocalizedString(@"Daily Check", nil), DTLocalizedString(@"ECG Recorder", nil), DTLocalizedString(@"Pulse Oximeter", nil),DTLocalizedString(@"Thermometer", nil),DTLocalizedString(@"Relax Me", nil),DTLocalizedString(@"Pedometer", nil)] mutableCopy];
            if ([UserList instance].isSpotCheck) {
                [imgNames removeLastObject];
                [titles removeLastObject];
                [titles replaceObjectAtIndex:0 withObject:DTLocalizedString(@"Spot Check", nil)];
            }
            cell = [[LeftMenuCell alloc]initWithImgName:[imgNames objectAtIndex:indexPath.row] andText:[titles objectAtIndex:indexPath.row]];
            
        } else {
            
            NSArray *imgNames = @[@"ljsetting_l.png",@"ljupdate_l.png",@"ljabout_l.png"];
            NSArray *titles = @[DTLocalizedString(@"Settings", nil),DTLocalizedString(@"Device Update",nil), DTLocalizedString(@"About", nil)];
            cell = [[LeftMenuCell alloc]initWithImgName:[imgNames objectAtIndex:indexPath.row] andText:[titles objectAtIndex:indexPath.row]];
        }
    }
    return cell;
}
 
@end
