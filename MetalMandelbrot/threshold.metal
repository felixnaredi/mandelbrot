//
//  infit.metal
//  MandelbrotScreenSaver
//
//  Created by Felix Naredi on 2020-07-06.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "complex.h"

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
  
template <class F>
int CountIterationsUntilThreshold( const complex_t<F> c
                                 , float threshold
                                 , uint max_iterations )
{
  auto z = c;
  int count = 0;
  
  while (max_iterations) {
    if (abs(z) >= threshold) { return count; }
    
    z = z * z + c;
    
    ++count;
    --max_iterations;
  }
  
  return -1;
}
  
template <class F>
auto Zn( const complex_t<F> c
        , const float threshold
        , uint max_iterations )
{
  auto z = c;
  while (max_iterations) {
    if (abs(z) >= threshold) { return z; }
    z = z * z + c;
    --max_iterations;
  }
  return complex_t<F>(0);
}
  
float4 BlendColors(float4 colorA, float4 colorB, float x)
{ return colorA * (1 - x) + colorB * x; }

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
  
  // Normalized distance between zero and max iterations.
  const auto i = CountIterationsUntilThreshold<float>(p.xy, threshold, max_iterations);
  if (i < 0) { return {0, 0, 0, 1}; }
  
  const auto zn = Zn<float>(p.xy, threshold, max_iterations);
  const auto log_zn = log(abs(zn)) / 2.0;
  const auto nu = log(log_zn / log(2.0f)) / log(2.0f);
  const auto x = (i + 1 - nu) / max_iterations;
  
  // Find color index greater than `x`.
  uint j = 1;
  while (x > color_gradient_indices[i]) { ++j; }
  
  // Find the blended color between the indices lesser and greater than `x`.
  const float b = (x - color_gradient_indices[j - 1])
                  / (color_gradient_indices[j] - color_gradient_indices[j - 1]);
  
  return BlendColors(float4(color_gradient[j - 1], 1), float4(color_gradient[j], 1), b);
}
  
} // namespace threshold
} // namespace mandelbrot
