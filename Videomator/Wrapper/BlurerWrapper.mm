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

- (instancetype) init:(NSString *) pbPath :(NSString *) pbTxtPath :(NSString *) tessPath {
    self = [super init];
    
    if (self != nil) {
        _blurer = new core_api::Blurer();
        _blurer->init([pbPath UTF8String], [pbTxtPath UTF8String], [tessPath UTF8String]);
    }
    
    NSLog(@"initialized");
    return self;
}

- (void) load:(NSString *)filepath {
    _blurer->load([filepath UTF8String]);
}

- (NSInteger) getFps {
    NSInteger fps = _blurer->get_fps();
    return fps;
}

- (NSInteger) getFrameCount {
    NSInteger frameCount = _blurer->get_frame_count();
    return frameCount;
}

- (void) startRender {
    _blurer->start_render();
}

- (BOOL) doneRendering {
    return _blurer->done_rendering();
}

- (void) createStream: (NSInteger) frameIndex {
    _blurer->create_stream((int)frameIndex);
}

- (void) playStream: (NSInteger) fps {
    int videoFps = (int)(fps > 0) ? (int)fps : _blurer->get_fps();
    _blurer->play_stream(videoFps);
}

- (void) pauseStream {
    _blurer->pause_stream();
}

- (NSImage *) streamBuffer {
    core_api::image_data data = _blurer->stream_buffer_preview();
    if (data.data == nullptr) {
        return NULL;
    }
    
    int len = (data.width - 1) * data.height * 3 + (data.height - 1) * 3 + (3 - 1);
    char * byteArray = new char[len];
    for (size_t i = 0; i < len; i += 3)
    {
        byteArray[i] = data.data[i + 2];
        byteArray[i + 1] = data.data[i + 1];
        byteArray[i + 2] = data.data[i];
    }
    
    const int bytesPerRow = data.width * 3;
    const unsigned int channels = 3;
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes:(unsigned char **)&byteArray
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

- (void) saveRendered:(NSString *)filepath {
    _blurer->save_rendered([filepath UTF8String]);
}
@end
