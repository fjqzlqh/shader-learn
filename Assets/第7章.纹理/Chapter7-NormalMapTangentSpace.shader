

Shader "UnityShader Book/Chapter 7/NormalMapTangentSpace"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _BumpMap("BumpMap", 2D) = "white" {}
        _BumpScale("BumpScale", Float) = 1.0
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
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _BumpMap;
            float _BumpScale;
            float4 _MainTex_ST;
            float4 _BumpMap_ST;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                //可以直接使用UnityCG.cginc下TANGENT_SPACE_ROTATION 替换下面两行
                //求副切线
                float3 binormal = cross(normalize(v.normal), v.tangent.xyz) * v.tangent.w; //w分量决定了方向 -1或者1
                //切线空间变换矩阵
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                
                //切线空间下的灯光和视角
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //自发光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //灯光
                fixed3 lightDir =  normalize(i.lightDir);
                //法线
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal); //将坐标从[0,1]映射回[-1,1] 
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy))); //因为是单位向量 所以z^2 = 1-x^2-y^2
                //视角
                float3 viewDir = normalize(i.viewDir);
                //BlinnPhong 公式
                float3 halfDir = normalize(lightDir + viewDir);
                //高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb *  pow(saturate(dot(halfDir, tangentNormal)), _Gloss);
                //纹理
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed3 color = tex.rgb * _LightColor0.rgb * _Diffuse.rgb * saturate(dot(tangentNormal, lightDir)) + specular + ambient;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
