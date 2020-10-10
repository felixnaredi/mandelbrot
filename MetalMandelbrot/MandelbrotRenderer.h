//
//  MandelbrotRenderer.h
//  MetalMandelbrot
//
//  Created by Felix Naredi on 2020-06-17.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

@import Metal;
@import simd;
@import Foundation;
#import <QuartzCore/CAMetalLayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface MandelbrotRenderer : NSObject

- (id)initWithDevice:(id<MTLDevice>)device library:(id<MTLLibrary>)library;
- (void)drawInLayer:(CAMetalLayer *)layer;

@property float width;
@property float height;

@property uint iterations;

@property void (^onWillRender)(MandelbrotRenderer *renderer);
@property Boolean isPaused;
@property simd_float4x4 modelMatrix;
@property float threshold;

@end

NS_ASSUME_NONNULL_END
