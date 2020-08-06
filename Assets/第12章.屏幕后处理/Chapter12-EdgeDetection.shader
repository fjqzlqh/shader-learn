Shader "UnityShader Book/Chapter 12/EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always ZWrite Off Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragSobel

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            float _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackGroundColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);

                return o;
            }

            fixed luminance(fixed4 color)
            {   
                return 0.2521 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            half sobel(v2f i)
            {
                const half GX[9] = {
                    -1,-2,-1,
                    0,0,0,
                    1,2,1
                };
                const half GY[9] = {
                    -1,0,1,
                    -2,0,2,
                    -1,0,1
                };
                half texColor;
                half edgeX = 0;
                half edgeY = 0;
                for (int index = 0; index < 9; index++) {
                    texColor = luminance(tex2D(_MainTex, i.uv[index]));
                    edgeX += texColor * GX[index];
                    edgeY += texColor * GY[index];
                }
                half edge = 1 - abs(edgeX) - abs(edgeY);
                return edge;
            }

            //soble是边缘检测的一种
            fixed4 fragSobel (v2f i) : SV_Target
            {
                half edge = sobel(i);

                // sample the texture
                fixed4 col = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
                fixed4 onlyCol = lerp(_EdgeColor, _BackGroundColor, edge);

                return lerp(col, onlyCol, _EdgeOnly);
            }
            ENDCG
        }
    }
}
