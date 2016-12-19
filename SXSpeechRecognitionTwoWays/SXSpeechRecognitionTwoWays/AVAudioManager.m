//
//  AVAudioManager.m
//  SXSpeechRecognitionTwoWays
//
//  Created by dongshangxian on 2016/12/15.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import "AVAudioManager.h"
#import <Speech/Speech.h>

@interface AVAudioManager()<SFSpeechRecognitionTaskDelegate>

/** 录音设备 */
@property (nonatomic, strong) AVAudioRecorder *recorder;
/** 监听设备 */
@property (nonatomic, strong) AVAudioRecorder *monitor;
/** 录音文件的URL */
@property (nonatomic, strong) NSURL *recordURL;
/** 监听器 URL */
@property (nonatomic, strong) NSURL *monitorURL;
/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation AVAudioManager

+ (instancetype)shareManager
{
    static AVAudioManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AVAudioManager alloc]init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    [self setupRecorder];
    return self;
}

/** 设置录音环境 */
- (void)setupRecorder {
    // 1. 音频会话
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
    
    // 参数设置
    NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithFloat: 14400.0], AVSampleRateKey,
                                    [NSNumber numberWithInt: kAudioFormatAppleIMA4], AVFormatIDKey,
                                    [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                    [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey,
                                    nil];
    
    NSString *recordPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"record.caf"];
    _recordURL = [NSURL fileURLWithPath:recordPath];
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:_recordURL settings:recordSettings error:NULL];
    
    // 监听器
    NSString *monitorPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"monitor.caf"];
    _monitorURL = [NSURL fileURLWithPath:monitorPath];
    _monitor = [[AVAudioRecorder alloc] initWithURL:_monitorURL settings:recordSettings error:NULL];
    _monitor.meteringEnabled = YES;
}

- (void)setupTimer {
    [self.monitor record];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
}

// 监听开始与结束的方法
- (void)updateTimer {

    // 不更新就没法用了
    [self.monitor updateMeters];
    
    // 获得0声道的音量，完全没有声音-160.0，0是最大音量
    float power = [self.monitor peakPowerForChannel:0];
    
    //        NSLog(@"%f", power);
    if (power > -20) {
        if (!self.recorder.isRecording) {
            NSLog(@"开始录音");
            [self.recorder record];
        }
    } else {
        if (self.recorder.isRecording) {
            NSLog(@"停止录音");
            [self.recorder stop];
            
            [self recognition];
        }
    }
}


/** 识别声音 */
- (void)recognition {
    // 时钟停止
    [self.timer invalidate];
    // 监听器也停止
    [self.monitor stop];
    // 删除监听器的录音文件
    [self.monitor deleteRecording];
    
    //创建语音识别操作类对象
    SFSpeechRecognizer *rec = [[SFSpeechRecognizer alloc]initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    //            SFSpeechRecognizer *rec = [[SFSpeechRecognizer alloc]initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en_ww"]];
    
    //通过一个本地的音频文件来解析
    SFSpeechRecognitionRequest * request = [[SFSpeechURLRecognitionRequest alloc]initWithURL:_recordURL];
    [rec recognitionTaskWithRequest:request delegate:self];
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%@",recognitionResult.bestTranscription.formattedString);
//    self.showLabel.text = recognitionResult.bestTranscription.formattedString;
//    NSTimeInterval cao = [[NSDate date]timeIntervalSince1970] - self.delay;
    [[NSNotificationCenter defaultCenter]postNotificationName:SPEECH_RECOGNITION_MSG object:nil userInfo:@{@"msg":recognitionResult.bestTranscription.formattedString}];
    [self setupTimer];
}

- (void)start{
    [self setupTimer];
}

- (void)stop{
    [self.timer invalidate];
}

@end
