//
//  DFImageFilter.h
//  DFImageFilterApp
//
//  Created by DF on 7/24/14.
//  Copyright (c) 2014 df. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
@interface DFImageFilter : NSObject
+(void)filteredImageWithImage:(UIImage *)image completion:(void(^)(CIImage *filteredImage))handler;
@end
