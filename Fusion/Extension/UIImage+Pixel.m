//
//  UIImage+Pixel.m
//  Fusion
//
//  Created by DevinShine on 2017/5/26.
//  Copyright © 2017年 DevinShine. All rights reserved.
//

#import "UIImage+Pixel.h"


@implementation UIImage (Pixel)

- (struct PixelData)pixelData {
    CGImageRef imageRef = [self CGImage];
    CGSize size = self.size;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(size.height * size.width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, size.width, size.height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), imageRef);
    CGContextRelease(context);
    
    struct PixelData pd;
    pd.rawData = rawData;
    pd.count = size.height * size.width * 4;
    pd.height = size.height;
    pd.width = size.width;
    pd.endIndex = pd.count;
    return pd;
}
@end
