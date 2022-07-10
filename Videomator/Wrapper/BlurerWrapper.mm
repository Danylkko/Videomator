//
//  BlurerWrapper.m
//  Videomator
//
//  Created by Danylo Litvinchuk on 09.07.2022.
//

#import "BlurerWrapper.h"
#import "Blurer.h"

@interface BlurerWrapper()
@property core_api::Blurer* blurer;
@end

@implementation BlurerWrapper

- (instancetype)init:(NSString *) netPath :(NSString *)tesseractPath {
    self = [super init];
    
    if (self != nil) {
        _blurer = new core_api::Blurer();
        _blurer->init([netPath UTF8String], [tesseractPath UTF8String]);
    }
    
    NSLog(@"initialized");
    return self;
}

- (void)load:(NSString *)filepath {
    _blurer->load([filepath UTF8String]);
}

- (void)detect:(NSInteger)detectionMode {
    _blurer->start_render(core_api::Blurer::detection_mode::all);
    _blurer->create_stream(0); // index of start frame
}

- (NSImage *)buffer {
    core_api::image_data data = _blurer->stream_buffer();
    const int bytesPerRow = data.width * 3;
    const unsigned int channels = 3;
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes:(unsigned char **)&data.data
                                pixelsWide:data.width
                                pixelsHigh:data.height
                                bitsPerSample:8
                                samplesPerPixel:channels
                                hasAlpha:NO
                                isPlanar:NO
                                colorSpaceName:NSDeviceRGBColorSpace
                                bytesPerRow:bytesPerRow
                                bitsPerPixel:8 * channels];
    
    NSImage* image = [[NSImage alloc]init];
    [image addRepresentation:bitmap];
    
    return image;
}


@end
