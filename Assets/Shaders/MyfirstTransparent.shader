Shader "Unlit/Conveyorbelt"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue"="Transparent"} // The 'Queue = Transparent' tells the shader to render the transparent type of rendering to render last, which means the 'solid cube' gets rendered first,
		//Then the transparent shader renders last, showing it to be 'over the top' be careful when rendering multiple transparent types ontop of each other otherwise it can have odd effects.


		Pass
		{

			//Ztest Greater // Same as below, but different, check API.
			//Ztest GEqual // This makes the shader invisible, UNLESS it is behind something.
			//Ztest Less // Look up API has to do with things rendering like xray effects, or
			//ZWrite Off // (Z is away from the camera, which means it is is not writing (something) to the z axis, which means we can see a solid cube behind our transparent shader.
			
			
			// The two below methods make things 'transparent'
			//Blend One One //(Look up Addative in notes)
			//Blend DSTColor One // Multiplative

			//Blend ScrA OneMinusSrcAlpha // Traditional Transparency
			//Blend One OneMinusSrcAlpha // Premultiplied transparency (One minus One = 0 so it does not render the background? (Im sick))
			//Blend DstColor SrcColor // 2x multiplicative
			
			//Cull Front // This removes the front facing 'face' of an object towards the camera.
			//Cull Back // This removes the back of the object that the camera cannot see
			//Cull Off // This essentially makes a Skybox, (as in the inside of the object renders instead of culling.) So you can move the camera inside a cube and still see all the rendering on the inside.

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float xOffset = cos(i.uv.x * UNITY_TWO_PI * 8) * 0.01;
				//float t = cos((i.uv.y + xOffset + 0.1) * UNITY_TWO_PI * 5) * 0.5 + 0.5;
				float t = cos((i.uv.y + xOffset - _Time.y + 0.3) * UNITY_TWO_PI * 5) * 0.5 + 0.5; // The - _Time.y + (speed) gave a conveyor like effect.

				t *= 1 - i.uv.y; // The 1 - makes it darker at the top, if you remove that it is whiter at the top.


				//return float4(t.xxx, 1);

				return t;

			}
			ENDCG
		}
	}
}
