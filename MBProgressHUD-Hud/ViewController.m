//
//  ViewController.m
//  MSProgressCategory
//
//  Created by lztb on 2019/8/22.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD+Hud.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,NSURLSessionDelegate>
{
    MBProgressHUD *mbprogressHud;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, copy) NSMutableArray *dataSources;

@property (atomic, assign) BOOL canceled;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    {
        self.dataSources = @[@[@"Indeterminate mode",@"With label",@"With details label"],@[@"Determinate mode",@"Annular determinate mode",@"Bar determinate mode",],@[@"Top Text only",@"Mid Text only",@"Bot Text only"],@[@"Custom view",@"With action button",@"Mode switching"],@[@"On window",@"NSURLSession",@"Colored"]].mutableCopy;
    }
    
    //    [MBProgressHUD mb_loading];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSources.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr= self.dataSources[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSArray *arr= self.dataSources[indexPath.section];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = arr[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *arr= self.dataSources[indexPath.section];
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            [MBProgressHUD mb_loading:nil];
        }else if (indexPath.row == 1){
            [MBProgressHUD mb_showMessage:arr[indexPath.row] detailMsg:nil onView:self.navigationController.view hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
        }else if (indexPath.row == 2){
            [MBProgressHUD mb_showMessage:arr[indexPath.row] detailMsg:@"index.row" onView:self.view hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD mb_hide];
        });
        
    }else if (indexPath.section == 1){
        MBProgressHUD *hud = nil;
        if (indexPath.row == 0) {
            hud = [MBProgressHUD mb_showDeterm:@"测试" detailMsg:@"详细信息" onView:nil hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
        }else if (indexPath.row == 1){
            hud = [MBProgressHUD mb_showAnnularDeterm:@"测试" detailMsg:nil onView:nil hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
        }else if (indexPath.row == 2){
            hud = [MBProgressHUD mb_showBar:@"测试" detailMsg:nil onView:nil hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            // Do something useful in the background and update the HUD periodically.
            [self doSomeWorkWithProgress:hud];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD mb_hide];
            });
        });
        
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            [MBProgressHUD mb_showTopMessage:[NSString stringWithFormat:@"%@显示",arr[indexPath.row]] onView:self.view  hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
        }else if (indexPath.row == 1){
            
            [MBProgressHUD mb_showMidMessage:[NSString stringWithFormat:@"%@显示",arr[indexPath.row]] onView:self.view  hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
            
            
        }else if (indexPath.row == 2){
            [MBProgressHUD mb_showBotMessage:[NSString stringWithFormat:@"%@显示",arr[indexPath.row]] onView:self.view  hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
            
        }
    }else if (indexPath.section ==3){
        if (indexPath.row == 0){
            NSMutableArray <UIImage *> *arr2 = [[NSMutableArray alloc] init];
            for (int i = 1; i<10; i++) {
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_hud_%d",i]];
                [arr2 addObject:image];
            }
            [MBProgressHUD mb_showImages:arr2 msg:@"请稍后..." onView:nil hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD mb_hide];
            });
            
        }else if (indexPath.row ==1){
            MBProgressHUD *hud = [MBProgressHUD mb_showMessage:arr[indexPath.row] detailMsg:nil onView:self.navigationController.view hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
            hud.mode = MBProgressHUDModeDeterminate;
            [hud.button setTitle:NSLocalizedString(@"Cancel", @"HUD cancel button title")  forState:UIControlStateNormal];
            [hud.button addTarget:self action:@selector(cancelWork:) forControlEvents:UIControlEventTouchUpInside];
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                // Do something useful in the background and update the HUD periodically.
                [self doSomeWorkWithProgress:hud];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                });
            });
        }else if (indexPath.row == 2){
            MBProgressHUD *hud = [MBProgressHUD mb_showMessage:@"请稍后..." detailMsg:nil onView:nil hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
            //            hud.minSize = CGSizeMake(150.f, 100.f);
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                // Do something useful in the background and update the HUD periodically.
                [self doSomeWorkWithMixedProgress:hud];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD mb_hide];
                });
            });
        }
    }
    
    else if (indexPath.section == 4){
        
        if (indexPath.row == 0) {
            [MBProgressHUD mb_showMessage:arr[indexPath.row] detailMsg:nil onView:self.view.window hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD mb_hide];
            });
            
        }else if(indexPath.row == 1){
            mbprogressHud = [MBProgressHUD mb_showMessage:arr[indexPath.row] detailMsg:nil onView:self.view.window hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
            [self doSomeNetworkWorkWithProgress];
        }else if(indexPath.row == 2){
            MBProgressHUD *hud = [MBProgressHUD mb_showMessage:arr[indexPath.row] detailMsg:nil onView:self.view.window hideBlock:^{
                NSLog(@"%@已消失",arr[indexPath.row]);
            }];
            hud.contentColor = [UIColor redColor];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD mb_hide];
            });
        }
    }
}

- (void)doSomeWorkWithProgress:(MBProgressHUD *)hud {
    self.canceled = NO;
    // This just increases the progress indicator in a loop.
    float progress = 0.0f;
    while (progress < 1.0f) {
        if (self.canceled) break;
        progress += 0.01f;
        dispatch_async(dispatch_get_main_queue(), ^{
            // Instead we could have also passed a reference to the HUD
            // to the HUD to myProgressTask as a method parameter.
            hud.progress = progress;
        });
        usleep(50000);
    }
}

- (void)doSomeWorkWithMixedProgress:(MBProgressHUD *)hud {
    // Indeterminate mode
    sleep(2);
    // Switch to determinate mode
    dispatch_async(dispatch_get_main_queue(), ^{
        hud.mode = MBProgressHUDModeDeterminate;
        hud.label.text = NSLocalizedString(@"Loading...", @"HUD loading title");
    });
    float progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.01f;
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.progress = progress;
        });
        usleep(50000);
    }
    // Back to indeterminate mode
    dispatch_async(dispatch_get_main_queue(), ^{
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = NSLocalizedString(@"Cleaning up...", @"HUD cleanining up title");
    });
    sleep(2);
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        hud.customView = imageView;
        hud.mode = MBProgressHUDModeCustomView;
        hud.label.text = NSLocalizedString(@"Completed", @"HUD completed title");
    });
    sleep(2);
}

- (void)doSomeNetworkWorkWithProgress {
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    NSURL *URL = [NSURL URLWithString:@"https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/HT1425/sample_iPod.m4v.zip"];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:URL];
    [task resume];
}

- (void)cancelWork:(id)sender {
    self.canceled = YES;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    
    // Update the UI on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self->mbprogressHud.mode = MBProgressHUDModeDeterminate;
        self->mbprogressHud.progress = progress;
        
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    // Do something with the data at location...
    
    // Update the UI on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self->mbprogressHud.customView = imageView;
        self->mbprogressHud.mode = MBProgressHUDModeCustomView;
        self->mbprogressHud.label.text = NSLocalizedString(@"Completed", @"HUD completed title");
        [self->mbprogressHud hideAnimated:YES afterDelay:1.5];
    });
}

@end


