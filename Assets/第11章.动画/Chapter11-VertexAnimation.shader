Shader "UnityShader Book/Chapter 11/VertexAnimation"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("颜色", Color) = (1,1,1,1)
        _Magnitude ("变形大小", Float) = 1
        _Frequency ("变形频率", Float) = 1
        _InvWaveLength ("波长的倒数", Float) = 100
        _Speed ("速度", Float) = 0.5
    }
    SubShader
    {
        //忽略投影 关闭批处理 
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True"}
        LOD 100
        
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
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
            fixed4 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                float4 offset;
                offset.xyzw = 0;
                offset.x = sin(_Frequency * _Time.y + v.vertex.z * _InvWaveLength + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength) * _Magnitude;
                o.vertex = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv +=  float2(0.0, _Time.y * _Speed);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color.rgb;
                return col;
            }
            ENDCG
        }
    }
}
