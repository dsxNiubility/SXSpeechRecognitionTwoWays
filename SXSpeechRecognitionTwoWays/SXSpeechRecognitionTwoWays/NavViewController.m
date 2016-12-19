//
//  NavViewController.m
//  SXSpeechRecognitionTwoWays
//
//  Created by dongshangxian on 2016/12/15.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import "NavViewController.h"
#import "ViewController2.h"

@interface NavViewController ()

@property(nonatomic,strong)UILabel *msgLabel;

@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reciveSRMessage:) name:SPEECH_RECOGNITION_MSG object:nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height * 0.8, [UIScreen mainScreen].bounds.size.width * 0.8, 60)];
    self.msgLabel.backgroundColor = [UIColor yellowColor];
    self.msgLabel.numberOfLines = 2;
    self.msgLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:234/255.0 blue:121/255.0 alpha:1];
    self.msgLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.msgLabel];
}


- (void)reciveSRMessage:(NSNotification *)no{
    NSLog(@"%@",no.userInfo);
    NSString *msg = no.userInfo[@"msg"];
    self.msgLabel.text = msg;
    
    if ([msg containsString:@"跳"] && [msg containsString:@"下一页"]) {
        ViewController2 *vc = [ViewController2 new];
        vc.view.backgroundColor = [UIColor whiteColor];
        [self pushViewController:vc animated:YES];
    }else if ([msg containsString:@"回"] && [msg containsString:@"首页"]){
        [self popToRootViewControllerAnimated:YES];
    }else if ([msg containsString:@"背景"] && [msg containsString:@"设置"]){
        UIView *v = self.topViewController.view;
        if ([msg containsString:@"红色"]) {
            v.backgroundColor = [UIColor redColor];
        }else if ([msg containsString:@"黄色"]){
            v.backgroundColor = [UIColor yellowColor];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
