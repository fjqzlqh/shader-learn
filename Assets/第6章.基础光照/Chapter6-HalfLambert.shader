// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "UnityShader Book/Chapter 6/Chapter6-HalfLambert"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldNormal : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_ObjectToWorld);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //自发光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightDir =  normalize(_WorldSpaceLightPos0.xyz);
                fixed4 col;
                //半兰伯特模型  把dot的[-1,1] 转变成[0-1]
                col.rgb = _LightColor0.rgb * _Diffuse.rgb * (dot(worldNormal, lightDir) * 0.5 + 0.5) + ambient;
                col.a = 1;
                return col;
            }
            ENDCG
        }
    }
}
