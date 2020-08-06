

Shader "UnityShader Book/Chapter 7/SingleTexture"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {} 
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
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float3 worldNormal : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
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
                o.worldNormal = mul(v.normal, (float3x3)unity_ObjectToWorld);
                o.worldPos = mul(o.vertex, (float3x3)unity_ObjectToWorld);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //自发光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //灯光
                float3 lightDir =  normalize(_WorldSpaceLightPos0.xyz);
                float3 worldNormal = normalize(i.worldNormal);
                
                //视角
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                //BlinnPhong 公式
                float3 halfDir = normalize(lightDir.xyz + viewDir);
                //高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb *  pow(saturate(dot(halfDir, worldNormal)), _Gloss);
                //纹理
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed3 color = tex.rgb * _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, lightDir)) + specular + ambient;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
