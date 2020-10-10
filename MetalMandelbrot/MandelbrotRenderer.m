//
//  MandelbrotRenderer.m
//  MetalMandelbrot
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
  if (!self) { return NULL; }
  
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
    if (error) { return; }
    
    self->_renderPipelineState = renderPipelineState;
    [self setIsPaused:NO];
  }];
  
  return self;
}

- (void)drawInLayer:(CAMetalLayer *)layer
{
  if (self.onWillRender != NULL) { self.onWillRender(self); }
  
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
        
    //
    // Color schemes.
    //
    
    /*
    // Arcane
    const float k = 1.5;
    const simd_float3 colors[] = {
      simd_make_float3(0.01, 0.01, 0.15),
      simd_make_float3(0.01, 0.01, 0.15),
      simd_make_float3(0.01, 0.01, 0.15),
      simd_make_float3(0.01, 0.01, 0.25),
      simd_make_float3(0.01, 0.01, 0.15),
      simd_make_float3(1.00, 0.80, 0.70),
      simd_make_float3(0.40, 0.25, 0.00),
      simd_make_float3(0.80, 0.65, 0.40),
      simd_make_float3(1.00, 0.80, 0.70),
      simd_make_float3(0.21, 0.21, 0.45),
      simd_make_float3(0.01, 0.01, 0.35),
      simd_make_float3(0.01, 0.01, 0.25),
      simd_make_float3(1.00, 0.80, 0.70),
    }; */
    
    
    // Ember
    const float k = 5.5;
    const simd_float3   colors[] = {
      simd_make_float3(0.05, 0.05, 0.1),
      simd_make_float3(9.0, 0.8, 0.4),
      simd_make_float3(0.6, 0.4, 0.0),
    };

    /*
    // Rainbow
    const float k = 1.0;
    const simd_float3   colors[] = {
      simd_make_float3(0.8, 0.0, 0.0),
      simd_make_float3(0.4, 0.6, 0.0),
      simd_make_float3(0.0, 0.8, 0.0),
      simd_make_float3(0.0, 0.4, 0.6),
      simd_make_float3(0.0, 0.0, 0.8),
      simd_make_float3(0.6, 0.0, 0.4),
    }; */
    
    //
    // Index generator.
    //
    
    const uint len = sizeof(colors) / sizeof(simd_float3);
    float color_indices[len];
    float s = 0;
    float c = 1.0;
    
    for (int i = 1; i < len; ++i) {
      s += 1.0 / c;
      color_indices[i] = s;
      c /= k;
    }
    for (int i = 1; i < len - 1; ++i) {
      color_indices[i] /= s;
    }
    color_indices[0] = 0;
    color_indices[len - 1] = 1;
    
    id<CAMetalDrawable> drawable = [layer nextDrawable];
    colorAttachment.resolveTexture = drawable.texture;
    
    id<MTLRenderCommandEncoder> commandEncoder =
      [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    
    [commandEncoder setRenderPipelineState: _renderPipelineState];
    
    [commandEncoder setFragmentBytes:&_modelMatrix    length:sizeof(_modelMatrix)  atIndex:0];
    [commandEncoder setFragmentBytes:&viewport        length:sizeof(viewport)      atIndex:1];
    [commandEncoder setFragmentBytes:&_iterations     length:sizeof(_iterations)   atIndex:2];
    [commandEncoder setFragmentBytes:&_threshold      length:sizeof(_threshold)    atIndex:3];
    [commandEncoder setFragmentBytes:&colors          length:sizeof(colors)        atIndex:4];
    [commandEncoder setFragmentBytes:&color_indices   length:sizeof(color_indices) atIndex:5];
    
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    
    [commandEncoder endEncoding];
    [commandBuffer presentDrawable:drawable];
  }
  
  // Commit render.
  [commandBuffer commit];
}


@end
