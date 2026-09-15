// Why: optional stitchable tint for iOS 17+ colorEffect. Canvas is the real cinema;
// this file only adds a faint energy wash. Adult light, no creatures.

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]] half4 energyTint(float2 position, half4 color, float time, float amount) {
    float wave = 0.5 + 0.5 * sin(time * 5.2 + position.x * 0.012 + position.y * 0.008);
    half3 wash = half3(0.70, 0.52, 1.0) * half(wave * amount * 0.35);
    half3 warm = half3(1.0, 0.86, 0.70) * half((1.0 - wave) * amount * 0.18);
    return half4(color.rgb + (wash + warm) * color.a, color.a);
}
