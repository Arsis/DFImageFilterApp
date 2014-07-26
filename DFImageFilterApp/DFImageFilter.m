//
//  DFImageFilter.m
//  DFImageFilterApp
//
//  Created by DF on 7/24/14.
//  Copyright (c) 2014 df. All rights reserved.
//

#import "DFImageFilter.h"

@implementation DFImageFilter
+(void)filteredImageWithImage:(UIImage *)image completion:(void(^)(CIImage *filteredImage))handler {
    
    CIImage *img = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *gamma = [CIFilter filterWithName:@"CIGammaAdjust"];
    [gamma setValue:img forKey:kCIInputImageKey];
    [gamma setValue:@(1.61) forKey:@"inputPower"];
    
    CIFilter *colorMatrixFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [colorMatrixFilter setDefaults];
    [colorMatrixFilter setValue:[CIVector vectorWithX:0.7 Y:0 Z:0 W:0]
                         forKey:@"inputRVector"];
    [colorMatrixFilter setValue:[CIVector vectorWithX:0 Y:1.2 Z:0 W:0]
                         forKey:@"inputGVector"];
    [colorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:2.3 W:0]
                         forKey:@"inputBVector"];
    [colorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1]
                         forKey:@"inputAVector"];
    [colorMatrixFilter setValue:gamma.outputImage
                     forKeyPath:kCIInputImageKey];
    
    CIFilter *filterForThread = [colorMatrixFilter copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIFilter *filter = filterForThread;
        CIImage *output = [filter outputImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            CIImage *result = [output copy];
            handler(result);
        });
        
    });
    
}
@end
