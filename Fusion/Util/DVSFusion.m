//
//  DVSFusion.m
//  Fusion
//  长图拼接功能实现
//  应用场景，手Q聊天截图的长图合并
//
//
//                                       Data Divide
//
//                                 ┌─────────────────────┐
//                                 │   Top(Navigation)   │
//                                 │                     │
//                                 ├─────────────────────┤
//                                 │                     │
//                                 │                     │
//                                 │                     │
//                                 │                     │
//                                 │                     │
//                                 │        Data         │
//                                 │                     │
//                                 │                     │
//                                 │                     │
//                                 │                     │
//                                 │                     │
//                                 ├─────────────────────┤
//                                 │       Bottom        │
//                                 │                     │
//                                 └─────────────────────┘
//
//
//
//
//                                         Example
//
//
//                              Prev                     Post
//
//                    ┌─────────────────────┐   ┌─────────────────────┐
//                    │   Top(Navigation)   │   │   Top(Navigation)   │
//                    │                     │   │                     │
//                    ├─────────────────────┤   ├─────────────────────┤
//                    │           ┌───────┐ │   │ ┌───────┐           │
//                    │           │  Hi   │ │   │ │  456  │           │
//                    │           └───────┘ │   │ └───────┘           │
//                    │ ┌───────┐           │   │           ┌───────┐ │
//                    │ │  123  │           │   │           │  789  │ │
//                    │ └───────┘           │   │           └───────┘ │
//                    │           ┌───────┐ │   │ ┌───────┐           │
//                    │           │  321  │ │   │ │  101  │           │
//                    │           └───────┘ │   │ └───────┘           │
//                    │ ┌───────┐           │   │           ┌───────┐ │
//                    │ │  456  │           │   │           │  189  │ │
//                    ├─┴───────┴───────────┤   ├───────────┴───────┴─┤
//                    │       Bottom        │   │       Bottom        │
//                    │                     │   │                     │
//                    └─────────────────────┘   └─────────────────────┘
//                               │                         │
//                               │          Merge          │
//                               └────────────┬────────────┘
//                                            │
//                                            │
//                                            ▼
//
//                                         Result
//
//                                 ┌─────────────────────┐
//                                 │   Top(Navigation)   │
//                                 │                     │
//                                 ├─────────────────────┤
//                                 │           ┌───────┐ │
//                                 │           │  Hi   │ │
//                                 │           └───────┘ │
//                                 │ ┌───────┐           │
//                                 │ │  123  │           │
//                                 │ └───────┘           │
//                                 │           ┌───────┐ │
//                                 │           │  321  │ │
//                                 │           └───────┘ │
//                                 │ ┌───────┐           │
//                                 │ │  456  │           │
//                                 │ └───────┘           │
//                                 │           ┌───────┐ │
//                                 │           │  789  │ │
//                                 │           └───────┘ │
//                                 │ ┌───────┐           │
//                                 │ │  101  │           │
//                                 │ └───────┘           │
//                                 │           ┌───────┐ │
//                                 │           │  189  │ │
//                                 ├───────────┴───────┴─┤
//                                 │       Bottom        │
//                                 │                     │
//                                 └─────────────────────┘
//  Created by DevinShine on 2017/5/26.
//  Copyright © 2017年 DevinShine. All rights reserved.
//

#import "DVSFusion.h"
#import "UIImage+Pixel.h"

@implementation DVSFusion

// min bottom height
int minBottomHeight = 49;
int minDuplicateRows = 300;

+ (UIImage *)mergeImages:(NSArray<UIImage *> *)images {
    if (images == nil) {
        return nil;
    } else if (images.count == 1) {
        return images[0];
    }

    unsigned char *prevPixelOrigin = [images[0] pixelData].rawData;
    int width = images[0].size.width;
    int height = images[0].size.height;
    int topHeight = 0, bottomHeight = 0, contentHeight = 0;

    unsigned char *topPixelData = NULL;
    unsigned char *bottomPixelData = NULL;
    struct PixelData dataArray[images.count];
    memset(dataArray, 0, sizeof(dataArray));
    for (int i = 1; i < images.count; i++) {
        struct PixelData postPixelData = [images[i] pixelData];
        struct PixelData *prevPixelContentData = NULL, *postPixelContentData = NULL;
        unsigned char *postPixelOrigin = postPixelData.rawData;
        if (i == 1) {
            NSArray *heights = [self getTopBottomHeight:postPixelOrigin prevPixel:prevPixelOrigin width:width height:height];
            topHeight = [heights[0] intValue];
            bottomHeight = [heights[1] intValue];
            contentHeight = height - topHeight - bottomHeight;

            // prev content
            int prevPixelContentCount = postPixelData.count - bottomHeight * width * 4 - topHeight * width * 4;
            int prevStartIndex = topHeight * width * 4;
            unsigned char *prevPixelContent = (unsigned char *)calloc(prevPixelContentCount, sizeof(unsigned char));
            for (int i = 0; i < prevPixelContentCount; i++) {
                prevPixelContent[i] = prevPixelOrigin[prevStartIndex++];
            }

            // post content
            int postPixelContentCount = prevPixelContentCount;
            int postStartIndex = topHeight * width * 4;
            unsigned char *postPixelContent = (unsigned char *)calloc(postPixelContentCount, sizeof(unsigned char));
            for (int i = 0; i < postPixelContentCount; i++) {
                postPixelContent[i] = postPixelOrigin[postStartIndex++];
            }

            // top content
            int topStartIndex = 0;
            topPixelData = (unsigned char *)calloc(topHeight * width * 4, sizeof(unsigned char));
            for (int i = 0; i < topHeight * width * 4; i++) {
                topPixelData[i] = prevPixelOrigin[topStartIndex++];
            }

            // bottom content
            if (bottomHeight > 0) {
                int bottomPixelCount = bottomHeight * width * 4;
                int bottomStartIndex = postPixelData.count - bottomPixelCount;
                bottomPixelData = (unsigned char *)calloc(bottomHeight * width * 4, sizeof(unsigned char));
                for (int i = 0; i < bottomPixelCount; i++) {
                    bottomPixelData[i] = prevPixelOrigin[bottomStartIndex++];
                }
            }

            struct PixelData prev = {
                prevPixelContent,
                prevPixelContentCount,
                width,
                prevPixelContentCount / width / 4,
                prevPixelContentCount};
            prevPixelContentData = &prev;

            struct PixelData post = {
                postPixelContent,
                postPixelContentCount,
                width,
                postPixelContentCount / width / 4,
                postPixelContentCount};
            postPixelContentData = &post;

            [self mergeInPrev:prevPixelContentData postPixel:postPixelContentData];

            dataArray[0] = *prevPixelContentData;
            dataArray[1] = *postPixelContentData;
        } else {
            // post content
            int postPixelContentCount = postPixelData.count - bottomHeight * width * 4 - topHeight * width * 4;
            int postStartIndex = topHeight * width * 4;
            unsigned char *postPixelContent = (unsigned char *)calloc(postPixelContentCount, sizeof(unsigned char));
            for (int i = 0; i < postPixelContentCount; i++) {
                postPixelContent[i] = postPixelOrigin[postStartIndex++];
            }
            struct PixelData post = {
                postPixelContent,
                postPixelContentCount,
                width,
                postPixelContentCount / width / 4,
                postPixelContentCount};
            postPixelContentData = &post;

            [self mergeInPrev:&dataArray[i - 1] postPixel:postPixelContentData];
            dataArray[i] = *postPixelContentData;
        }

        if (i == images.count - 1) {
            dataArray[i] = *postPixelContentData;
        }
        free(postPixelOrigin);
    }
    int dataCount = 0;
    for (int i = 0; i < images.count; i++) {
        dataCount += dataArray[i].endIndex;
    }
    int resultCount = (topHeight + bottomHeight) * width * 4 + dataCount;
    unsigned char *result = (unsigned char *)calloc(resultCount, sizeof(unsigned char));
    int i = 0;
    for (int j = 0; j < topHeight * width * 4; j++) {
        result[i] = topPixelData[j];
        i++;
    }
    for (int j = 0; j < images.count; j++) {
        for (int k = 0; k < dataArray[j].endIndex; k++) {
            result[i] = dataArray[j].rawData[k];
            i++;
        }
    }
    for (int j = 0; j < bottomHeight * width * 4; j++) {
        result[i] = bottomPixelData[j];
        i++;
    }
    UIImage *image = [self pixel2Image:result width:width height:topHeight + bottomHeight + dataCount / width / 4];

    if (topPixelData != NULL) {
        free(topPixelData);
    }
    if (bottomPixelData != NULL) {
        free(bottomPixelData);
    }

    for (int i = 0; i < images.count; i++) {
        free(dataArray[i].rawData);
    }

    free(prevPixelOrigin);

    return image;
}

+ (UIImage *)pixel2Image:(unsigned char *)pixels
                   width:(int)width
                  height:(int)height {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(pixels, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    CFRelease(colorSpace);
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    UIImage *newimage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    free(pixels);
    return newimage;
}

+ (NSArray *)getTopBottomHeight:(unsigned char *)postPixel
                      prevPixel:(unsigned char *)prevPixel
                          width:(int)width
                         height:(int)height {
    int topHeight = 0;
    int bottomHeight = 0;
    int count = width * height * 4;
    for (int i = 0; i < count; i++) {
        if (prevPixel[i] != postPixel[i]) {
            topHeight = i / width / 4;
            break;
        }
    }
    for (int i = count - 1; i >= 0; i--) {
        if (prevPixel[i] != postPixel[i]) {
            bottomHeight = height - i / width / 4 - 1;
            break;
        }
    }

    if (bottomHeight < minBottomHeight) { // clear
        bottomHeight = 0;
    }
    return @[ @(topHeight), @(bottomHeight) ];
}

+ (void)mergeInPrev:(struct PixelData *)prevPixelData
          postPixel:(struct PixelData *)postPixelData {
    int duplicateRow = 60;
    int duplicateEnd = postPixelData->width * 4 * duplicateRow;
    unsigned char *duplicatePixelData = (unsigned char *)calloc(duplicateEnd, sizeof(unsigned char));
    for (int i = 0; i < duplicateEnd; i++) {
        duplicatePixelData[i] = postPixelData->rawData[i];
    }
    int targetEndIndex = prevPixelData->endIndex - 1;
    bool isLoop = true;
    int loopCount = 1;
    int minErrorCount = duplicateEnd * 0.02;

    while (isLoop) {
        int equalCount = 0;
        for (int i = duplicateEnd - 1; i >= 0; i--) {
            if (duplicatePixelData[i] != prevPixelData->rawData[targetEndIndex]) {
                if (duplicateEnd - equalCount >= minErrorCount) {
                    break;
                }
            } else {
                targetEndIndex--;
                equalCount++;
            }
        }
        float p = equalCount * 1.0 / duplicateEnd;
        if (p >= 1.0) {
            prevPixelData->endIndex = targetEndIndex + 1;
            break;
        } else {
            if (targetEndIndex <= postPixelData->width * 4 * minDuplicateRows) {
                // 一般走到这就认为没必要继续跑了，也就是两图没重复
                break;
            }
            targetEndIndex = prevPixelData->count - loopCount * prevPixelData->width * 4 - 1;
            loopCount++;
        }
    }
    free(duplicatePixelData);
}
@end
