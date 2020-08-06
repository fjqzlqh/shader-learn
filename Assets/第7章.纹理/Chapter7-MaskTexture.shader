// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "UnityShader Book/Chapter 7/MaskTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "white" {}
        _BumpScale ("BumpScale", Float) = 1
        _SpecularMask ("SpecularMask", 2D) = "white" {}
        _SpecularScale ("SpecularScale", Float) = 1
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
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir :TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpecularScale;
            float4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //求副切线
                float3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 lightDir = normalize(i.lightDir);
                fixed3 viewDir = normalize(i.viewDir);
                
                fixed4 packedNormal = tex2D(_BumpMap, i.uv);
                fixed3 normal = UnpackNormal(packedNormal);
                normal.xy *= _BumpScale;
                normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));

                fixed3 diffuse = tex2D(_MainTex, i.uv).rgb * _LightColor0.rgb * saturate(dot(lightDir, normal));

                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed scale = tex2D(_SpecularMask, i.uv).r * _SpecularScale;//获取遮罩纹理的强度
                fixed3 specular = _LightColor0.rgb * pow(saturate(dot(halfDir, normal)), _Gloss) * scale;

                fixed3 col = diffuse + specular + ambient;
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
