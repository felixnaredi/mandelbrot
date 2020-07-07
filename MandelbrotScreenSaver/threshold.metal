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
                                 , uint max_iterations
                                 )
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
                              , constant uint& iterations [[buffer(2)]]
                              , constant float& threshold [[buffer(3)]]
                              )
{
  float4 p = in.position * float4(viewport, 1, 1) * model_matrix;
  int k = CountIterationsUntilThreshold(p.xy, threshold, iterations);
  
  if (k < 0) { return float4(0, 0, 0, 1); }
  return Color(float(k) / float(iterations));
}
  
} // namespace threshold
} // namespace mandelbrot
