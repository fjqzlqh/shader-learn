// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "UnityShader Book/Chapter 6/Chapter6-SpecularVertexLevel"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
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
                fixed3 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_ObjectToWorld));
                //自发光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //灯光
                float3 lightDir =  normalize(_WorldSpaceLightPos0.xyz);
                //反射公式 r = 2dot(光线方向, 法线方向)*法线方向 + (-光线方向);
                float3 r = normalize(2 * dot(o.worldNormal, lightDir) * o.worldNormal - lightDir);
                //视角
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, o.vertex.xyz));
                //高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb *  pow(saturate(dot(viewDir, r)), _Gloss);
                o.color = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(o.worldNormal, lightDir)) + specular + ambient;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1);
            }
            ENDCG
        }
    }
}
