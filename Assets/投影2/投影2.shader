// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'

Shader "Unlit/投影2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            blend DstColor Zero
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
                float4 uv_proj : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4x4 unity_Projector;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_proj = mul(unity_Projector, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float2 uv = i.uv_proj.xy / i.uv_proj.w;
                // sample the texture
                fixed4 col = tex2Dproj(_MainTex, UNITY_PROJ_COORD(i.uv_proj));
                col.rgb = 1-col.a;
                return col;
            }
            ENDCG
        }
    }
}
