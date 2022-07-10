//
//  BlurerWrapper.h
//  Videomator
//
//  Created by Danylo Litvinchuk on 09.07.2022.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlurerWrapper : NSObject
- (instancetype)init:(NSString *) pbPath :(NSString *) tesseractPath;
- (void)load: (NSString *) filepath;
- (void)detect: (NSInteger) detectionMode;
- (NSImage *) buffer;
@end

NS_ASSUME_NONNULL_END
