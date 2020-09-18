Shader "UnityShader Book/Chapter 12/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bloom ("Bloom (RGB)", 2D) = "black" {}
        _LuminanceThreshold ("Luminance Threshold", Float) = 0.5
        _BlurSize("BlurSize", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGINCLUDE

        sampler2D _MainTex;
        float4 _MainTex_ST;
        half4 _MainTex_TexelSize;
        sampler2D _Bloom;
		float _LuminanceThreshold;
        float _BlurSize;

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

        v2f vertExtractBright(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);

            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            return o;
        }

        //亮度计算
        fixed luminance(fixed4 color){
            return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
        }

        fixed4 fragExtractBright(v2f i):SV_TARGET
        {
            fixed4 c = tex2D(_MainTex, i.uv);
            //clamp 取值范围为0,1 
            fixed val = clamp(luminance(c) - _LuminanceThreshold, 0.0, 1.0);
            return fixed4((c * val).rgb, 1.0);
        }

        struct v2fBloom
        {
            half4 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        v2fBloom vertBloom(appdata v)
        {
            v2fBloom o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.uv;
            o.uv.zw = v.uv;

            //平台差异
            #if UNITY_UV_STARTS_AT_TOP			
			if (_MainTex_TexelSize.y < 0.0)
				o.uv.w = 1.0 - o.uv.w;
			#endif

            return o;
        }

        fixed4 fragBloom(v2fBloom i):SV_TARGET
        {
            return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
        }

        ENDCG
        
        ZTest Always ZWrite Off Cull Off
        //提取亮度高于_LuminanceThreshold的像素 
        Pass
        {
            NAME "GAUSSIAN_BLUR_VERTICAL"
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright

            ENDCG
        }
        //进行模糊处理
        UsePass "UnityShader Book/Chapter 12/GaussianBlur/GAUSSIAN_BLUR_VERTICAL"
        UsePass "UnityShader Book/Chapter 12/GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"

        //把上面处理的rt与原图进行叠加
        Pass
        {
            NAME "GAUSSIAN_BLUR_HORIZONTAL"
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom

            ENDCG
        }
    }
}
