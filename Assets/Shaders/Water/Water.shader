Shader "Custom/Water"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0


        _WaterFogColor ("Water Fog Color", Color) = (0,0,0,0)
        _WaterFogDensity ("Water Fog Density", Range (0,1)) = 0.5
        _RefractionStrength ("Refraction Strength", Range(0,1)) = 0.25

        _WaveA ("waveA (Direction, Steepness, Wavelength)", Vector) = (1,0,5,10)
        _WaveB ("waveA (Direction, Steepness, Wavelength)", Vector) = (0,1,0.25,20)
        _WaveC ("waveA (Direction, Steepness, Wavelength)", Vector) = (1,1,0.15,10)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "Queue"="Transparent"
        }

        LOD 200

        GrabPass
        {
            "_WaterBackground"
        }


        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha vertex:vert finalcolor:ResetAlpha // fullforwardShadows addshadow // addshadow makes other objects shadows move with the wave.



        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        #include "LookingThroughWater.cginc"

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;


        float4 _WaveA, _WaveB, _WaveC;

        float3 GerstnerWave(float4 wave, float3 pnt, inout float3 tangent, inout float3 binormal)
        {
            //Deconstruct float 4 wave
            float2 direction = normalize((wave.xy));
            float steepness = wave.z;
            float wavelength = wave.w;

            wavelength = 2 * UNITY_PI / wavelength;
            float speed = sqrt(9.8 / wavelength);
            float f = wavelength * (dot(direction, pnt.xz) - speed * _Time.y);
            float amplitude = steepness / wavelength;

            tangent += float3(1 - direction.x * direction.x * (steepness * sin(f)),
                              direction.x * (steepness * cos(f)),
                              - direction.x * direction.y * (steepness * sin(f)));
            binormal += float3(
                - direction.x * direction.y * (steepness * sin(f)),
                direction.y * (steepness * cos(f)),
                - direction.y * direction.y * (steepness * sin(f)));

            return float3(
                direction.x * (amplitude * cos(f)),
                amplitude * sin(f),
                direction.y * (amplitude * cos(f)));
        }

        void ResetAlpha(Input IN, SurfaceOutputStandard o, inout fixed4 color)
        {
            color.a = 1;
        }

        void vert(inout appdata_full vertexData)
        {
            float3 vert = vertexData.vertex.xyz;
            float3 tangent = float3(1, 0, 0);
            float3 binormal = float3(0, 0, 1);
            float3 pnt = vert;
            pnt += GerstnerWave(_WaveA, vert, tangent, binormal);
            pnt += GerstnerWave(_WaveB, vert, tangent, binormal);
            pnt += GerstnerWave(_WaveC, vert, tangent, binormal);


            //set values
            vertexData.vertex.xyz = pnt;
            vertexData.normal = normalize(cross(binormal, tangent));
        }


        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            o.Emission = ColourBelowWater(IN.screenPos, o.Normal) * (1 - c.a);
        }
        ENDCG
    }

}