//
//  AVAudioPlayerWrapper.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 08. 22.
//
//  last update: 12.07.18.
//

#pragma once
#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#warning This class is deprecated. Use 'MultipleSoundPlayer' instead.

#import "FileUtil.h"

@protocol AVAudioPlayerWrapperDelegate;

@interface AVAudioPlayerWrapper : NSObject <AVAudioPlayerDelegate> {
	
	AVAudioPlayer* player;
	
	NSMutableArray* filenames;
	NSTimer* playTimer;
	
	float gap;
	
	NSString* lastPlayedFilename;
	
	id<AVAudioPlayerWrapperDelegate> delegate;
	
	BOOL startAfterEachFinish;
	
	PathType filePathType;
	
	float volume;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
	float rate;
#endif
}

- (id)init;
+ (AVAudioPlayerWrapper*)sharedInstance;
+ (void)disposeSharedInstance;

- (BOOL)playSound:(NSString*)filename;
- (BOOL)playSound:(NSString *)filename pathType:(PathType)pathType;

/**
 * start a batch play of multiple sound files
 * 
 * @someGap: gap between each sound play
 * @startAfterPreviousSoundsFinish: whether to start next sound after previous one's complete finish, or not
 * @someDelay: start this batch play after someDelay
 */
- (void)playSounds:(NSArray*)someFilenames withGap:(float)someGap afterEachFinish:(BOOL)startAfterPreviousSoundsFinish delay:(float)someDelay;
- (void)playSounds:(NSArray*)someFilenames pathType:(PathType)pathType withGap:(float)someGap afterEachFinish:(BOOL)startAfterPreviousSoundsFinish delay:(float)someDelay;

- (void)stopSound;

- (NSTimeInterval)getCurrentTime;
- (void)setCurrentTime:(NSTimeInterval)newCurrentTime;

- (float)currentVolume;
- (void)setVolume:(float)newVolume;

- (BOOL)isPlaying;

- (AVAudioPlayer*)player;

@property (assign) id<AVAudioPlayerWrapperDelegate> delegate;
@property (getter=getCurrentTime, setter=setCurrentTime:) NSTimeInterval currentTime;
@property (getter=currentVolume, setter=setVolume:) float volume;
@property (readonly, getter=isPlaying) BOOL playing;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
@property (getter=getCurrentRate, setter=setCurrentRate:) float rate;
#endif

@end

@protocol AVAudioPlayerWrapperDelegate <NSObject>

- (void)audioPlayerWrapper:(AVAudioPlayerWrapper*)wrapper willStartPlayingFilename:(NSString*)filename;
- (void)audioPlayerWrapper:(AVAudioPlayerWrapper*)wrapper didStartPlayingFilename:(NSString*)filename;
- (void)audioPlayerWrapper:(AVAudioPlayerWrapper*)wrapper didFinishPlayingFilename:(NSString*)filename;
- (void)audioPlayerWrapper:(AVAudioPlayerWrapper*)wrapper didFinishPlayingSuccessfully:(BOOL)success;

@optional

- (void)audioPlayerWrapper:(AVAudioPlayerWrapper*)wrapper beginInterruption:(AVAudioPlayer*)player;
- (void)audioPlayerWrapper:(AVAudioPlayerWrapper*)wrapper endInterruption:(AVAudioPlayer*)player;

@end
