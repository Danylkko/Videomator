//
//  BlurerWrapper.h
//  Videomator
//
//  Created by Danylo Litvinchuk on 09.07.2022.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface BlurerWrapper : NSObject
- (instancetype) init:(NSString *) pbPath :(NSString *) tesseractPath;
- (void) load: (NSString *) filepath;
- (NSInteger) getFps;
- (NSInteger) getFrameCount;
- (void) startRender;
- (void) createStream;
- (void) playStream: (NSInteger *) fps;
- (void) pauseStream;
- (NSImage *) streamBuffer;
- (void) saveRendered: (NSString *) filepath;
@end
