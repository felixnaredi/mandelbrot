//
//  infit.metal
//  MandelbrotScreenSaver
//
//  Created by Felix Naredi on 2020-07-06.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

#include <metal_stdlib>
#include "complex.h"
using namespace metal;

namespace mandelbrot {
namespace threshold {

struct vertex_output_t
{
  float4 _position [[position]];
  float4 position;
  
  vertex_output_t(float4 position)
  : _position(position)
  , position(position)
  { }
};
  
int CountIterationsUntilThreshold( const complex_t c
                                 , float threshold
                                 , uint max_iterations )
{
  complex_t z = c;
  int count = 0;
  
  while (max_iterations) {
    if (abs(z) >= threshold) { return count; }
    
    z = z * z + c;
    
    ++count;
    --max_iterations;
  }
  
  return -1;
}
  
float4 BlendColors(float4 colorA, float4 colorB, float x)
{ return colorA * (1 - x) + colorB * x; }
  
float4 Color(float x)
{
  switch (uint(x * 30201) % 5) {
    case 0: return float4(0.1, 0.8, 0.4, 1.0) * x + float4(0.3, 0.1, 0.8, 1.0) * (1 - x);
    case 1: return float4(0.4, 0.1, 0.8, 1.0) * x + float4(0.8, 0.3, 0.1, 1.0) * (1 - x);
    case 2: return float4(0.2, 0.9, 0.5, 1.0) * x + float4(0.2, 0.0, 0.7, 1.0) * (1 - x);
    case 3: return float4(0.3, 0.0, 0.7, 1.0) * x + float4(0.9, 0.4, 0.2, 1.0) * (1 - x);
  }
  return float4(0.8, 0.4, 0.1, 1.0) * x + float4(0.1, 0.8, 0.3, 1.0) * (1 - x);
}

vertex vertex_output_t VertexShader(uint index [[vertex_id]])
{
  switch (index) {
    case 0: return { {  1.0,  1.0, 0.0, 1.0 } };
    case 1: return { { -1.0,  1.0, 0.0, 1.0 } };
    case 2: return { {  1.0, -1.0, 0.0, 1.0 } };
    case 3: return { { -1.0, -1.0, 0.0, 1.0 } };
  }
  return { float4() };
}
  
fragment float4 FragmentShader( vertex_output_t in [[stage_in]]
                              , constant float4x4& model_matrix [[buffer(0)]]
                              , constant float2& viewport [[buffer(1)]]
                              , constant uint& max_iterations [[buffer(2)]]
                              , constant float& threshold [[buffer(3)]]
                              , constant float3* color_gradient [[buffer(4)]]
                              , constant float* color_gradient_indices [[buffer(5)]]
                              )
{
  const float4 p = in.position * float4(viewport, 1, 1) * model_matrix;
  const int k = CountIterationsUntilThreshold(p.xy, threshold, max_iterations);
  
  if (k < 0) { return { 0, 0, 0, 1 }; }
  
  // Normalized distance between zero and max iterations.
  const float x = float(k) / float(max_iterations);
  
  // Find color index greater than `x`.
  uint i = 1;
  while (x > color_gradient_indices[i]) { ++i; }
  
  // Find the blended color between the indices lesser and greater than `x`.
  const float b = (x - color_gradient_indices[i - 1])
                  / (color_gradient_indices[i] - color_gradient_indices[i - 1]);
  
  return BlendColors(float4(color_gradient[i - 1], 1), float4(color_gradient[i], 1), b);
}
  
} // namespace threshold
} // namespace mandelbrot
