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

    }];
}


- (IBAction)restartBufferR:(id)sender {
}

- (IBAction)startBufferR:(id)sender {
    
    self.bufferRec = [[SFSpeechRecognizer alloc]initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    self.bufferEngine = [[AVAudioEngine alloc]init];
    
    if (_bufferTask != nil) {
        [_bufferTask cancel];
        _bufferTask = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    [audioSession setActive:true error:nil];
    
    self.bufferRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
    AVAudioInputNode *inputNode = [self.bufferEngine inputNode];
    self.buffeInputNode = inputNode;
    SFSpeechAudioBufferRecognitionRequest *tempRecognitionRequest = self.bufferRequest;
    
    tempRecognitionRequest.shouldReportPartialResults = true;
    
    self.bufferTask = [self.bufferRec recognitionTaskWithRequest:tempRecognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        
        if (result != nil) {
            self.showBufferText.text = result.bestTranscription.formattedString;
        }
        
        if (error != nil) {
            NSLog(@"%@",error.userInfo);
        }
    }];
    
    AVAudioFormat *format =[inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.bufferRequest appendAudioPCMBuffer:buffer];
    }];
    
    [self.bufferEngine prepare];
    
    [self.bufferEngine startAndReturnError:nil];
    
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
