//
//  BufferPlayerViewController.m
//  AVAudioPlayerNodeSample
//
//  Created by hiraya.shingo on 2015/02/06.
//  Copyright (c) 2015年 Shingo Hiraya. All rights reserved.
//

#import "BufferPlayerViewController.h"

@import AVFoundation;

@interface BufferPlayerViewController ()

@property (nonatomic, strong) AVAudioEngine *engine;
@property (nonatomic, strong) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, strong) AVAudioFile *audioFile;
@property (nonatomic, strong) AVAudioPCMBuffer *audioPCMBuffer;
@property (nonatomic, weak) IBOutlet UISwitch *loopSwitch;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation BufferPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.engine = [AVAudioEngine new];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loop.m4a" ofType:nil];
    self.audioFile = [[AVAudioFile alloc] initForReading:[NSURL fileURLWithPath:path]
                                                   error:nil];
    
    AVAudioFormat *audioFormat = self.audioFile.processingFormat;
    AVAudioFrameCount length = (AVAudioFrameCount)self.audioFile.length;
    self.audioPCMBuffer = [[AVAudioPCMBuffer alloc]initWithPCMFormat:audioFormat frameCapacity:length];
    [self.audioFile readIntoBuffer:self.audioPCMBuffer error:nil];
    
    self.audioPlayerNode = [[AVAudioPlayerNode alloc] init];
    [self.engine attachNode:self.audioPlayerNode];
    
    // Connect Nodes
    AVAudioMixerNode *mixerNode = [self.engine mainMixerNode];
    [self.engine connect:self.audioPlayerNode
                      to:mixerNode
                  format:self.audioFile.processingFormat];
    
    // Start the engine.
    NSError *error;
    [self.engine startAndReturnError:&error];
    if (error) {
        NSLog(@"error:%@", error);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - private methods

- (void)play
{
    if (self.loopSwitch.isOn) {
        [self.audioPlayerNode scheduleBuffer:self.audioPCMBuffer
                                      atTime:nil
                                     options:AVAudioPlayerNodeBufferLoops
                           completionHandler:nil];
    } else {
        [self.audioPlayerNode scheduleBuffer:self.audioPCMBuffer
                                      atTime:nil
                                     options:AVAudioPlayerNodeBufferInterrupts
                           completionHandler:nil];
    }
    [self.audioPlayerNode play];
}

- (IBAction)didTapPlayButton:(id)sender
{
    if (self.audioPlayerNode.isPlaying) {
        [self.audioPlayerNode stop];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        self.loopSwitch.enabled = YES;
    } else {
        [self play];
        [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.loopSwitch.enabled = NO;
    }
}

- (IBAction)didChangeVolumeSliderValue:(id)sender
{
    float value = ((UISlider *)sender).value;
    [self.engine mainMixerNode].outputVolume = value;
}

- (IBAction)didChangePanSliderValue:(id)sender
{
    float value = ((UISlider *)sender).value;
    self.audioPlayerNode.pan = value;
}

@end
