Shader "Unlit/Fresnel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", color) = (1,1,1,1)
        _Strength("Strength", range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" 
            "Queue" = "Transparent" }

        Pass
        {
            Blend One One
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 worldPosition: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Strength;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize (i.normal);

                float3 V = normalize(_WorldSpaceCameraPos - i.worldPosition);

                float fresnel = (1 - dot(V,N)) * (cos(_Time.y * 5) * _Strength + _Strength);

                return float4(fresnel.xxx * _Color,1);
            }
            ENDCG
        }
    }
}
