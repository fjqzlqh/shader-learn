// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'



Shader "UnityShader Book/Chapter 7/NormalMapWorldSpace"
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
                float4 T2W0 : TEXCOORD1;
                float4 T2W1 : TEXCOORD2;
                float4 T2W2 : TEXCOORD3;
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
                //世界位置
                float3 worldPos =  normalize(mul(unity_ObjectToWorld, o.pos));//UnityWorldToObjectDir(o.pos);
                //世界法线
                float3 worldNormal = normalize(mul(unity_ObjectToWorld, v.normal)); //UnityObjectToWorldNormal(v.normal);
                //世界切线
                float3 worldTangent = normalize(mul(unity_ObjectToWorld, v.tangent.xyz));//UnityWorldToObjectDir(v.tangent.xyz);
                //世界副切线
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                //切线空间到世界空间的矩阵
                o.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //自发光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //灯光
                fixed3 lightDir =  normalize(_WorldSpaceLightPos0.xyz);
                //法线
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal); //将坐标从[0,1]映射回[-1,1] 
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy))); //因为是单位向量 所以z^2 = 1-x^2-y^2

                float3x3 rotation = float3x3(i.T2W0.xyz, i.T2W1.xyz, i.T2W2.xyz);
                float3 normal = normalize(mul(rotation, tangentNormal));
                //世界顶点位置
                float3 worldPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);
                //视角
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);//UnityWorldSpaceViewDir(worldPos);
                //BlinnPhong 公式
                float3 halfDir = normalize(lightDir + viewDir);
                //高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb *  pow(saturate(dot(halfDir, normal)), _Gloss);
                //纹理
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed3 color = tex.rgb * _LightColor0.rgb * _Diffuse.rgb * saturate(dot(normal, lightDir)) + specular + ambient;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
