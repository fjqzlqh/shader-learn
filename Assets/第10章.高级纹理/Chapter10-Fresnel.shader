﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "UnityShader Book/Chapter 10/Fresnel"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
        _Cubemap ("Reflection Cubemap", Cube) = "_Skybox" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldPos: TEXCOORD0;
                float3 worldNormal: TEXCOORD1;
                float3 worldViewDir: TEXCOORD2;
                float3 worldRefl: TEXCOORD3;
                SHADOW_COORDS(4)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed3 _Color;
            fixed _FresnelScale;
            samplerCUBE _Cubemap;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                //反射
                o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldViewDir = normalize(i.worldViewDir);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rbg;
                fixed3 diffuse = _LightColor0.rgb * _Color.rbg * saturate(dot(worldNormal, worldLightDir));
                //i.worldRefl 不需要nromalize 因为只需要方向
                fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;
                //菲涅尔
                fixed3 fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 color = ambient + lerp(diffuse, reflection, saturate(fresnel)) * atten;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
