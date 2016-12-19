//
//  ViewController.m
//  SXSpeechRecognitionTwoWays
//
//  Created by dongshangxian on 2016/12/15.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import "ViewController.h"
#import "AVAudioManager.h"
#import <Speech/Speech.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *showBufferText;
@property (weak, nonatomic) IBOutlet UIButton *restartBtn;



@property(nonatomic,strong)SFSpeechRecognizer *bufferRec;
@property(nonatomic,strong)SFSpeechAudioBufferRecognitionRequest *bufferRequest;
@property(nonatomic,strong)SFSpeechRecognitionTask *bufferTask;
@property(nonatomic,strong)AVAudioEngine *bufferEngine;
@property(nonatomic,strong)AVAudioInputNode *buffeInputNode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        // 对结果枚举的判断
        if(status != SFSpeechRecognizerAuthorizationStatusAuthorized){
            NSLog(@"不给权限直接强退");
            [@[] objectAtIndex:1];
        }
    }];
    [[AVAudioManager shareManager] start];
}


- (IBAction)restartBufferR:(id)sender {
    
}

- (IBAction)startBufferR:(id)sender {
    
    self.bufferRec = [[SFSpeechRecognizer alloc]initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    self.bufferEngine = [[AVAudioEngine alloc]init];
    self.buffeInputNode = [self.bufferEngine inputNode];
    
    if (_bufferTask != nil) {
        [_bufferTask cancel];
        _bufferTask = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    [audioSession setActive:true error:nil];
    
    // block外的代码也都是准备工作，参数初始设置等
    self.bufferRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
    self.bufferRequest.shouldReportPartialResults = true;
    __weak ViewController *weakSelf = self;
    self.bufferTask = [self.bufferRec recognitionTaskWithRequest:self.bufferRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        
        if (result != nil) {
            weakSelf.showBufferText.text = result.bestTranscription.formattedString;
        }
        if (error != nil) {
            NSLog(@"%@",error.userInfo);
        }
    }];
    
    // 监听一个标识位并拼接流文件
    AVAudioFormat *format =[self.buffeInputNode outputFormatForBus:0];
    [self.buffeInputNode installTapOnBus:0 bufferSize:1024 format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [weakSelf.bufferRequest appendAudioPCMBuffer:buffer];
    }];
    
    // 准备并启动引擎
    [self.bufferEngine prepare];
    NSError *error = nil;
    if (![self.bufferEngine startAndReturnError:&error]) {
        NSLog(@"%@",error.userInfo);
    };
    self.showBufferText.text = @"等待命令中.....";
}

- (IBAction)stopBufferR:(id)sender {
    [self.bufferEngine stop];
    [self.buffeInputNode removeTapOnBus:0];
    self.showBufferText.text = @"";
    self.bufferRequest = nil;
    self.bufferTask = nil;
}


- (IBAction)startURLR:(id)sender {
    [[AVAudioManager shareManager] start];
}
- (IBAction)stopURLR:(id)sender {
    [[AVAudioManager shareManager] stop];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
