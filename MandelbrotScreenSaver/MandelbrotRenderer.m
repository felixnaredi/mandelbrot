//
//  MandelbrotRenderer.m
//  MandelbrotScreenSaver
//
//  Created by Felix Naredi on 2020-06-17.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

@import simd;
@import Metal;
#import <QuartzCore/CAMetalLayer.h>
#import "MandelbrotRenderer.h"

#define SAMPLE_COUNT 8

static float maxf(float a, float b)
{ return a > b ? a : b; }

@implementation MandelbrotRenderer
{
  // Metal state variables.
  id<MTLDevice> _device;
  id<MTLCommandQueue> _commandQueue;
  id<MTLRenderPipelineState> _renderPipelineState;
  id<MTLTexture> _antiAliasingTexture;
  
  // Used to indicate when to update `_antiAliasingTexture`
  CALayer __weak * _oldLayer;
};

- (id)initWithDevice:(id<MTLDevice>)device library:(id<MTLLibrary>)library
{
  self = [super init];
  
  if (!self) {
    return NULL;
  }
  
  self.modelMatrix = simd_matrix(simd_make_float4(1, 0, 0, 0),
                                 simd_make_float4(0, 1, 0, 0),
                                 simd_make_float4(0, 0, 1, 0),
                                 simd_make_float4(0, 0, 0, 1));
  self.iterations = 0;
  
  _device = device;
  _commandQueue = [device newCommandQueue];
  _antiAliasingTexture = NULL;
  
  MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
  pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"mandelbrot::threshold::VertexShader"];
  pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"mandelbrot::threshold::FragmentShader"];
  pipelineDescriptor.sampleCount = SAMPLE_COUNT;
  pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
  
  [device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                             completionHandler:^(id<MTLRenderPipelineState> renderPipelineState,
                                                 NSError *error) {
    if (error) {
      return;
    }
    self->_renderPipelineState = renderPipelineState;
    [self setIsPaused:NO];
  }];
  
  return self;
}

- (void)drawInLayer:(CAMetalLayer *)layer
{
  if (self.onWillRender != NULL) {
    self.onWillRender(self);
  }
  
  id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
  
  // Update anti-aliasing texture if target layer has changed.
  if (_oldLayer != layer) {
    CGSize size = layer.frame.size;
    MTLTextureDescriptor *descripor = [MTLTextureDescriptor
                                        texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                        width:size.width
                                        height:size.height
                                        mipmapped:NO];
    descripor.storageMode = MTLStorageModePrivate;
    descripor.sampleCount = SAMPLE_COUNT;
    descripor.textureType = MTLTextureType2DMultisample;
    descripor.usage = MTLTextureUsageRenderTarget;
    
    _antiAliasingTexture = [_device newTextureWithDescriptor:descripor];
    _oldLayer = layer;
  }
  
  // Setup the render pass descriptor.
  
  MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor new];
  MTLRenderPassColorAttachmentDescriptor *colorAttachment = renderPassDescriptor.colorAttachments[0];
  colorAttachment.loadAction = MTLLoadActionClear;
  colorAttachment.storeAction = MTLStoreActionMultisampleResolve;
  colorAttachment.clearColor = MTLClearColorMake(0.1, 0.2, 0.3, 1.0);
  colorAttachment.texture = _antiAliasingTexture;
  
  // Last possible point to fetch a drawable.
  @autoreleasepool {
    const uint          _iterations     = maxf(0.0, self.iterations);
    const simd_float4x4 _modelMatrix    = self.modelMatrix;
    const float         _threshold      = self.threshold;
    const simd_float2   viewport        = simd_make_float2(1, self.height / self.width);
    
    id<CAMetalDrawable> drawable = [layer nextDrawable];
    colorAttachment.resolveTexture = drawable.texture;
    
    id<MTLRenderCommandEncoder> commandEncoder =
      [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    
    [commandEncoder setRenderPipelineState: _renderPipelineState];
    
    [commandEncoder setFragmentBytes:&_modelMatrix length:sizeof(_modelMatrix) atIndex:0];
    [commandEncoder setFragmentBytes:&viewport     length:sizeof(viewport)     atIndex:1];
    [commandEncoder setFragmentBytes:&_iterations  length:sizeof(_iterations)  atIndex:2];
    [commandEncoder setFragmentBytes:&_threshold   length:sizeof(_threshold)   atIndex:3];
    
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    
    [commandEncoder endEncoding];
    [commandBuffer presentDrawable:drawable];
  }
  
  // Commit render.
  [commandBuffer commit];
}


@end
