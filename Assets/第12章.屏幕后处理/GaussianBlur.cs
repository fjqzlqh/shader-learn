using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{
    public Shader gaussianShader;
    private Material gaussianMaterial;

    public Material material{
        get{
            gaussianMaterial = CheckShaderAndCreateMaterial(gaussianShader, gaussianMaterial);
            return gaussianMaterial;
        }
    }

    [Range(0, 4)]
    public int iterations = 3;//迭代次数
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;//模糊范围
    [Range(1, 8)]
    public int downSample = 2;//缩放系数

    void OnRenderImage(RenderTexture src, RenderTexture dest){
        if(material){
            material.SetInt("_Iterations", iterations);
            material.SetFloat("_BlurSpread", blurSpread);
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(src, buffer0);
            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, material, 0); //使用第一个pass
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, material, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
