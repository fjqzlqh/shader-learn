// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "UnityShader Book/Chapter 11/Billboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Vertica1Billboarding("垂直限制", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue"="Transparent"}
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Vertica1Billboarding;

            v2f vert (appdata v)
            {
                v2f o;
                float3 center = float3(0,0,0);
                //以视角当法线
                float3 normalDir = mul(unity_WorldToObject, _WorldSpaceCameraPos).xyz - center;
                normalDir.y = normalDir.y * _Vertica1Billboarding;
                normalDir = normalize(normalDir);
                //向上
                float3 upDir = abs(normalDir.y) > 0.999 ? fixed3(0,0,1):fixed3(0,1,0);
                float3 rightDir = normalize(cross(upDir, normalDir));
                upDir = normalize(cross(normalDir, rightDir));

                float3 centerOffs = v.vertex.xyz - center;
                float3x3 rotation = float3x3(rightDir, upDir, normalDir);
                float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                o.vertex = UnityObjectToClipPos(float4(localPos, 1));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
