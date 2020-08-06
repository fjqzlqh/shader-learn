// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "UnityShader Book/Chapter 7/RampTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RampTxt ("RampTxt", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos :TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _RampTxt;
            float4 _RampTxt_ST;
            float4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _RampTxt);
                o.worldPos = mul(unity_ObjectToWorld, o.pos);
                o.worldNormal = mul(unity_ObjectToWorld, v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldPos = normalize(i.worldPos);
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed halfLambert = dot(worldLight, worldNormal) * 0.5 + 0.5;
                fixed3 diffuseColor = tex2D(_RampTxt, fixed2(halfLambert, 0.5)).xyz; //根据漫反射的强度来取对应UV上的颜色
                fixed3 diffuse = _LightColor0.rgb * diffuseColor;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                fixed3 halfDir = normalize(worldLight + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rbg * pow(saturate(dot(halfDir, worldNormal)), _Gloss);
                fixed3 col = diffuse + specular + ambient;
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
