//
//  NavViewController.m
//  SXSpeechRecognitionTwoWays
//
//  Created by dongshangxian on 2016/12/15.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import "NavViewController.h"

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
    self.msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height * 0.8, [UIScreen mainScreen].bounds.size.width * 0.8, 100)];
    self.msgLabel.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.msgLabel];
}


- (void)reciveSRMessage:(NSNotification *)no{
    NSLog(@"%@",no.userInfo);
    self.msgLabel.text = no.userInfo[@"msg"];
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
