//
//  UIImage+Pixel.h
//  Fusion
//
//  Created by DevinShine on 2017/5/26.
//  Copyright © 2017年 DevinShine. All rights reserved.
//

#import <UIKit/UIKit.h>
struct PixelData
{
    unsigned char *rawData;
    int count;
    int width;
    int height;
    int endIndex;
};
@interface UIImage (Pixel)
- (struct PixelData)pixelData;
@end
