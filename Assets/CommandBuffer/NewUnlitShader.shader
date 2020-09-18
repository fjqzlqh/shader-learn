Shader "Unlit/Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Outline Color", Color) = (1, 0, 0, 1)
        _Q ("1", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        LOD 100

        Pass
        {
            //Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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
                float3 wordNormal : TEXCOORD1;
                float3 viewDir:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _Q;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.wordNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.viewDir = normalize(UnityWorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed3 wordNormal = normalize(i.wordNormal);
                // fixed3 viewDir = normalize(i.viewDir);
                fixed3 wordNormal = i.wordNormal;
                fixed3 viewDir = i.viewDir;
                fixed4 c = tex2D(_MainTex, i.uv);
                fixed a = max(0, 1 - saturate(dot(wordNormal, viewDir)) - _Q);
                return lerp(c, _Color, a);
            }
            ENDCG
        }
    }
}
