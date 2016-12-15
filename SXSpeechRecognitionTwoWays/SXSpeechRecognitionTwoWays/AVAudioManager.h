//
//  AVAudioManager.h
//  SXSpeechRecognitionTwoWays
//
//  Created by dongshangxian on 2016/12/15.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVAudioManager : NSObject

+ (instancetype)shareManager;

- (void)start;
- (void)stop;

@end
