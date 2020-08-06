Shader "UnityShader Book/Chapter 11/ImageSequenceAnimation"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _DetailTex ("Detail Texture", 2D) = "white" {}
        _ScrollX ("Scroll X", Float) = 1
        _ScrollX2 ("Scroll X2", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
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
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            float _ScrollX;
            float _ScrollX2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + float2(_ScrollX, 0) * _Time.y;
                // o.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex) + float2(_ScrollX2, 0) * _Time.y;
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + frac(float2(_ScrollX, 0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex) + frac(float2(_ScrollX2, 0) * _Time.y);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                fixed4 col2 = tex2D(_DetailTex, i.uv.zw);
                fixed4 ret = lerp(col, col2, 1 - col.a);
                return ret;
            }
            ENDCG
        }
    }
}
