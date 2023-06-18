#if !defined(LOOKING_THROUGH_WATER_INCLUDED)
#define LOOKING_THROUGH_WATER_INCLUDED

//filled out by Unity
sampler2D _CameraDepthTexture;
float4 _CameraDepthTexture_TexelSize;

//Filled by grabpass
sampler2D _WaterBackground;

//Filled by Properties
float3 _WaterFogColor;
float _WaterFogDensity;
float _RefractionStrength;

float2 AlignWithGrabTexel(float2 uv)
{
    #if UNITY_UV_STARTS_AT_TOP
    if (_CameraDepthTexture_TexelSize.y < 0)
    {
        uv.y = 1 - uv.y;
    }
    #endif

    return (floor(uv * _CameraDepthTexture_TexelSize.zw) + 0.5) * abs(_CameraDepthTexture_TexelSize.xy);
}


float3 ColourBelowWater(float4 screenPos, float3 tangentSpaceNormal)
{
    float2 uvOffset = tangentSpaceNormal.xy * _RefractionStrength;
    uvOffset.y *= _CameraDepthTexture_TexelSize.z * abs(_CameraDepthTexture_TexelSize.y);
    float2 uv = AlignWithGrabTexel((screenPos.xy + uvOffset) / screenPos.w);

    //depth relative to the screen
    float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
    //how far away the surface of the water is
    float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);
    //depth from water to stuff underwater.
    float depthDifference = backgroundDepth - surfaceDepth;


    uvOffset *= saturate(depthDifference);
    uv = AlignWithGrabTexel(screenPos.xy + uvOffset / screenPos.w);
    backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
    depthDifference = backgroundDepth - surfaceDepth;

    float3 backgroundColor = tex2D(_WaterBackground, uv).rgb;
    float fogFactor = exp2(-_WaterFogDensity * depthDifference);


    return lerp(_WaterFogColor, backgroundColor, fogFactor);
}


#endif
