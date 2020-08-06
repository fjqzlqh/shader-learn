Shader "UnityShader Book/Chapter 8/AlphaTestBothSided"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" "IgnoreProjector"="True" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            Cull off

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Cutoff;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldPos = normalize(i.worldPos);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                fixed halfLambert = dot(lightDir, worldNormal) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * halfLambert;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                //alpha Test
                clip(col.a - _Cutoff);

                col.xyz *= diffuse;
                col.xyz += ambient;
                return col;
            }
            ENDCG
        }
    }
}
