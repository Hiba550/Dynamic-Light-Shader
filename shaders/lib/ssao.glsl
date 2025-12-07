//lib
//GNU Affero General Public License v3.0

#ifndef SSAO_GLSL
#define SSAO_GLSL

#ifndef OPTIONS_GLSL
#include "/lib/options.glsl"
#endif

#ifndef SSAO_ENABLED
    #define SSAO_ENABLED 1
#endif

#ifndef SSAO_STRENGTH
    #define SSAO_STRENGTH 0.4
#endif

#ifndef SSAO_RADIUS
    #define SSAO_RADIUS 1.0
#endif

#ifndef SSAO_SAMPLES
    #define SSAO_SAMPLES 16
#endif


#ifndef TAA_ENABLED
    #define TAA_ENABLED 1
#endif

#ifndef TAA_BLEND
    #define TAA_BLEND 0.85
#endif

#ifndef TAA_SHARPNESS
    #define TAA_SHARPNESS 0.2
#endif

float interleavedGradientNoise(vec2 coord) {
    return fract(52.9829189 * fract(0.06711056 * coord.x + 0.00583715 * coord.y));
}

float blueNoiseHash(vec2 p, float seed) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yxz + 33.33 + seed);
    return fract((p3.x + p3.y) * p3.z);
}

float getLinearDepth(float depth, float near, float far) {
    return near * far / (far - depth * (far - near));
}


const vec2 poissonDisk32[32] = vec2[](
    vec2(-0.613392, 0.617481), vec2(0.170019, -0.040254), vec2(-0.299417, 0.791925), vec2(0.645680, 0.493210),
    vec2(-0.651784, 0.717887), vec2(0.421003, 0.027070), vec2(-0.817194, -0.271096), vec2(-0.705374, -0.668203),
    vec2(0.977050, -0.108615), vec2(0.063326, 0.142369), vec2(0.203528, 0.214331), vec2(-0.667531, 0.326090),
    vec2(-0.098422, -0.295755), vec2(-0.885922, 0.215369), vec2(0.566637, 0.605213), vec2(0.039766, -0.396100),
    vec2(0.751946, 0.453352), vec2(0.078707, -0.715323), vec2(-0.075838, -0.529344), vec2(0.724479, -0.580798),
    vec2(0.222999, -0.215125), vec2(-0.467574, -0.405438), vec2(-0.248268, -0.814753), vec2(0.354411, -0.887570),
    vec2(0.175817, 0.382366), vec2(0.487472, -0.063082), vec2(-0.084078, 0.898312), vec2(0.488876, -0.783441),
    vec2(0.470016, 0.217933), vec2(-0.696890, -0.549791), vec2(-0.149693, 0.605762), vec2(0.034211, 0.979980)
);

vec2 getSpiralSampleOffset(int index, int totalSamples, float rotation) {
    float angle = float(index) * 2.4 + rotation; // Golden angle
    float radius = sqrt(float(index) / float(totalSamples));
    return vec2(cos(angle), sin(angle)) * radius;
}

float calculateVanillaSSAO(sampler2D depthTex, vec2 texcoord, float centerDepth,
                           float near, float far, vec2 texelSize) {
    
    #if SSAO_ENABLED == 0
        return 1.0;
    #endif
    
    if (centerDepth >= 0.9999) return 1.0;
    float linearCenterDepth = getLinearDepth(centerDepth, near, far);
    if (linearCenterDepth > 150.0) return 1.0;
    float noise = blueNoiseHash(gl_FragCoord.xy, 0.0);
    float rotAngle = noise * 6.28318;
    float cosR = cos(rotAngle);
    float sinR = sin(rotAngle);
    float baseRadius = SSAO_RADIUS * 0.012;
    float adaptiveRadius = baseRadius * (1.0 + linearCenterDepth * 0.015);
    adaptiveRadius = clamp(adaptiveRadius, 0.002, 0.04);
    float occlusion = 0.0;
    float weightSum = 0.0;
    int sampleCount = SSAO_SAMPLES;
    
    for (int i = 0; i < sampleCount; i++) {
        vec2 offset;
        if (i < 32) {
            offset = poissonDisk32[i];
        } else {
            offset = getSpiralSampleOffset(i, sampleCount, rotAngle);
        }
        
        vec2 rotatedOffset = vec2(
            offset.x * cosR - offset.y * sinR,
            offset.x * sinR + offset.y * cosR
        );
        
        float scale = 0.5 + float(i % 4) * 0.25;
        vec2 sampleCoord = texcoord + rotatedOffset * adaptiveRadius * scale;
        
        if (sampleCoord.x < 0.001 || sampleCoord.x > 0.999 || 
            sampleCoord.y < 0.001 || sampleCoord.y > 0.999) continue;
        
        float sampleDepth = texture(depthTex, sampleCoord).r;
        
        if (sampleDepth >= 0.9999) continue;
        
        float linearSampleDepth = getLinearDepth(sampleDepth, near, far);
        float depthDiff = linearCenterDepth - linearSampleDepth;
        
        float sampleDist = length(offset) * scale;
        float distWeight = 1.0 - sampleDist * 0.4;
        distWeight = max(distWeight, 0.1);
        
        float rangeLimit = linearCenterDepth * 0.12 + 0.4;
        float minRange = 0.005 + linearCenterDepth * 0.001;
        
        if (depthDiff > minRange && depthDiff < rangeLimit) {
            // Smooth falloff curve
            float normalizedDiff = (depthDiff - minRange) / (rangeLimit - minRange);
            float falloff = 1.0 - normalizedDiff * normalizedDiff;
            falloff = max(falloff, 0.0);
            
            occlusion += falloff * distWeight;
        }
        
        weightSum += distWeight;
    }
    
    if (weightSum < 0.01) return 1.0;
    
    occlusion /= weightSum;
    
    float ao = 1.0 - (occlusion * SSAO_STRENGTH * 1.2);
    
    ao = clamp(ao, 0.55, 1.0);
    
    float distanceFade = smoothstep(100.0, 150.0, linearCenterDepth);
    ao = mix(ao, 1.0, distanceFade);
    
    ao = mix(1.0, ao, smoothstep(0.0, 1.5, linearCenterDepth));
    
    return ao;
}

vec3 RGBToYCoCg(vec3 rgb) {
    return vec3(
        0.25 * rgb.r + 0.5 * rgb.g + 0.25 * rgb.b,
        0.5 * rgb.r - 0.5 * rgb.b,
        -0.25 * rgb.r + 0.5 * rgb.g - 0.25 * rgb.b
    );
}

vec3 YCoCgToRGB(vec3 ycocg) {
    return vec3(
        ycocg.x + ycocg.y - ycocg.z,
        ycocg.x + ycocg.z,
        ycocg.x - ycocg.y - ycocg.z
    );
}

vec3 sampleCatmullRom5Tap(sampler2D tex, vec2 uv, vec2 texelSize) {
    vec2 position = uv / texelSize;
    vec2 centerPosition = floor(position - 0.5) + 0.5;
    vec2 f = position - centerPosition;
    vec2 w0 = f * (-0.5 + f * (1.0 - 0.5 * f));
    vec2 w1 = 1.0 + f * f * (-2.5 + 1.5 * f);
    vec2 w2 = f * (0.5 + f * (2.0 - 1.5 * f));
    vec2 w3 = f * f * (-0.5 + 0.5 * f);
    vec2 w12 = w1 + w2;
    vec2 tc0 = (centerPosition - 1.0) * texelSize;
    vec2 tc12 = (centerPosition + w2 / w12) * texelSize;
    vec2 tc3 = (centerPosition + 2.0) * texelSize;
    vec3 result = vec3(0.0);
    float weightSum = 0.0;
    
    float weight;
    weight = w12.x * w0.y;
    result += texture(tex, vec2(tc12.x, tc0.y)).rgb * weight;
    weightSum += weight;
    weight = w0.x * w12.y;
    result += texture(tex, vec2(tc0.x, tc12.y)).rgb * weight;
    weightSum += weight;
    weight = w12.x * w12.y;
    result += texture(tex, vec2(tc12.x, tc12.y)).rgb * weight;
    weightSum += weight;
    weight = w3.x * w12.y;
    result += texture(tex, vec2(tc3.x, tc12.y)).rgb * weight;
    weightSum += weight;
    weight = w12.x * w3.y;
    result += texture(tex, vec2(tc12.x, tc3.y)).rgb * weight;
    weightSum += weight;
    
    return result / max(weightSum, 0.0001);
}

vec3 clipToAABBYCoCg(vec3 color, vec3 minimum, vec3 maximum) {
    vec3 center = 0.5 * (maximum + minimum);
    vec3 extents = 0.5 * (maximum - minimum) + 0.0001;
    vec3 offset = color - center;
    vec3 ts = abs(extents / (abs(offset) + 0.0001));
    float t = min(min(ts.x, ts.y), ts.z);
    t = clamp(t, 0.0, 1.0);
    
    return center + offset * t;
}

void getNeighborhoodStats(sampler2D tex, vec2 uv, vec2 texelSize, 
                          out vec3 minColor, out vec3 maxColor, out vec3 avgColor) {
    vec3 m1 = vec3(0.0);  // Mean
    vec3 m2 = vec3(0.0);  // Variance
    minColor = vec3(10.0);
    maxColor = vec3(0.0);
    const float weights[9] = float[](1.0, 2.0, 1.0, 2.0, 4.0, 2.0, 1.0, 2.0, 1.0);
    float totalWeight = 0.0;
    int idx = 0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec3 sampleColor = texture(tex, uv + vec2(x, y) * texelSize).rgb;
            vec3 sampleYCoCg = RGBToYCoCg(sampleColor);
            float w = weights[idx++];
            m1 += sampleColor * w;
            m2 += sampleColor * sampleColor * w;
            totalWeight += w;
            minColor = min(minColor, sampleColor);
            maxColor = max(maxColor, sampleColor);
        }
    }
    
    m1 /= totalWeight;
    m2 /= totalWeight;
    avgColor = m1;
    vec3 variance = sqrt(max(m2 - m1 * m1, vec3(0.0)));
    vec3 strictMin = m1 - variance * 1.0;
    vec3 strictMax = m1 + variance * 1.0;
    minColor = mix(strictMin, minColor, 0.5);
    maxColor = mix(strictMax, maxColor, 0.5);
}

vec3 applySharpening(vec3 color, sampler2D tex, vec2 uv, vec2 texelSize, float strength) {
    if (strength < 0.001) return color;
    vec3 n = texture(tex, uv + vec2(0.0, -1.0) * texelSize).rgb;
    vec3 s = texture(tex, uv + vec2(0.0, 1.0) * texelSize).rgb;
    vec3 e = texture(tex, uv + vec2(1.0, 0.0) * texelSize).rgb;
    vec3 w = texture(tex, uv + vec2(-1.0, 0.0) * texelSize).rgb;
    vec3 blur = (n + s + e + w) * 0.25;
    vec3 sharpened = color + (color - blur) * strength;
    vec3 minVal = min(min(n, s), min(e, w));
    vec3 maxVal = max(max(n, s), max(e, w));
    
    return clamp(sharpened, minVal * 0.9, maxVal * 1.1);
}

vec3 applyImprovedTAA(vec3 currentColor, sampler2D currentTex, sampler2D historyTex, 
                       vec2 texcoord, vec2 texelSize, vec2 prevUV, float depth) {
    
    #if TAA_ENABLED == 0
        return currentColor;
    #endif
    if (prevUV.x < 0.0 || prevUV.x > 1.0 || prevUV.y < 0.0 || prevUV.y > 1.0) {
        return currentColor;
    }
    
    vec2 velocity = texcoord - prevUV;
    float velocityMag = length(velocity * vec2(1920.0, 1080.0)); // Approximate pixel velocity
    vec3 historyColor = sampleCatmullRom5Tap(historyTex, prevUV, texelSize);
    vec3 minColor, maxColor, avgColor;
    getNeighborhoodStats(currentTex, texcoord, texelSize, minColor, maxColor, avgColor);
    float expansionFactor = mix(1.0, 1.3, smoothstep(0.0, 5.0, velocityMag));
    vec3 boxCenter = (minColor + maxColor) * 0.5;
    vec3 boxExtents = (maxColor - minColor) * 0.5 * expansionFactor;
    minColor = boxCenter - boxExtents;
    maxColor = boxCenter + boxExtents;
    historyColor = clamp(historyColor, minColor, maxColor);
    float baseBlend = TAA_BLEND;
    float motionReduction = smoothstep(0.0, 10.0, velocityMag);
    float adaptiveBlend = mix(baseBlend, baseBlend * 0.3, motionReduction);
    float edgeDist = min(min(prevUV.x, 1.0 - prevUV.x), min(prevUV.y, 1.0 - prevUV.y));
    adaptiveBlend *= smoothstep(0.0, 0.05, edgeDist);
    vec3 result = mix(currentColor, historyColor, adaptiveBlend);
    result = applySharpening(result, currentTex, texcoord, texelSize, TAA_SHARPNESS);
    return result;
}

vec3 applyTAA(vec3 currentColor, sampler2D historyTex, vec2 texcoord, vec2 texelSize, vec2 velocity) {
    vec2 historyUV = texcoord - velocity;
    if (historyUV.x < 0.0 || historyUV.x > 1.0 || historyUV.y < 0.0 || historyUV.y > 1.0) {
        return currentColor;
    }
    vec3 historyColor = texture(historyTex, historyUV).rgb;
    vec3 minColor = currentColor;
    vec3 maxColor = currentColor;
    
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            if (x == 0 && y == 0) continue;
            vec3 sampleColor = texture(historyTex, texcoord + vec2(x, y) * texelSize).rgb;
            minColor = min(minColor, sampleColor);
            maxColor = max(maxColor, sampleColor);
        }
    }
    
    vec3 boxCenter = (minColor + maxColor) * 0.5;
    vec3 boxExtents = (maxColor - minColor) * 0.5 + 0.01;
    minColor = boxCenter - boxExtents * 1.25;
    maxColor = boxCenter + boxExtents * 1.25;
    
    historyColor = clamp(historyColor, minColor, maxColor);
    
    return mix(currentColor, historyColor, TAA_BLEND);
}

#endif // SSAO_GLSL
