Shader "Eran/Simple 2D Water"
{
	Properties
	{
		_SurfaceScale ("Surface Scale",Range(0,1)) = 1
		[NoScaleOffset]_MainTex ("Surface Bg", 2D) = "white" {}

		_BumpScale ("Bump Scale",Range(0,1)) = 1
		[NoScaleOffset]_BumpTex ("Bump Texture", 2D) = "white"{}

		_BumpDir ("Dir 1,2",Vector) = (0,0,0,0)
        _BumpSpeed1 ("Bump Speed1",Range(0,1)) = 0
        _BumpSpeed2 ("Bump Speed2",Range(0,1)) = 0
        _BumpPower ("Bump Power",Range(0,2)) = 0
        _BgTwickPower ("Bg Power",Range(0,2)) = 0

		_SunColor("SunLight Color", Color) = (1,1,1,1)
		_SunBlend ("Sun Blend",Range(0,1)) = 1
        [NoScaleOffset]_SunTex ("SunLight Texture", 2D) = "white"{}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}

		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float _SurfaceScale;
			sampler2D _MainTex;

			sampler2D _BumpTex;
			float _BumpScale;

			sampler2D _SunTex;
			half4 _SunColor;
			fixed _SunBlend;

			float4 _BumpDir;
			float _BumpSpeed1;
			float _BumpSpeed2;
			float _BumpPower;
			float _BgTwickPower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = mul(unity_ObjectToWorld, v.vertex).xz;
				o.uv.z = 0.5 + o.vertex.x * 0.5 ;
				o.uv.w = 0.5 - o.vertex.y * 0.5 ;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 b1 = UnpackNormal(tex2D(_BumpTex,i.uv.xy * _BumpScale + _Time.yy * _BumpDir.xy * _BumpSpeed1));
				fixed3 b2 = UnpackNormal(tex2D(_BumpTex,i.uv.xy * _BumpScale + _Time.yy * _BumpDir.zw * _BumpSpeed2));

				fixed4 bgCol = tex2D(_MainTex, i.uv.xy * _SurfaceScale + b1 * _BgTwickPower);
				fixed4 bump = tex2D(_SunTex,i.uv.zw + (b1+b2) * _BumpPower);

				fixed4 sumCol = lerp(bgCol,_SunColor,bump.x);

				fixed4 col = lerp(bgCol,sumCol,_SunBlend);
				return col;
			}
			ENDCG
		}
	}
}
