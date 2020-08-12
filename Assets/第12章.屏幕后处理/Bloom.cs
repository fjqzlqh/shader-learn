using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectsBase
{
    public Shader bloomShader;
    private Material bloomMaterial;

    public Material material{
        get{
            bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
            return bloomMaterial;
        }
    }
    //----高斯模糊的参数----
    [Range(0, 4)]
    public int iterations = 3;//迭代次数
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;//模糊范围
    [Range(1, 8)]
    public int downSample = 2;//缩放系数
    //----高斯模糊的参数----

    //亮度临界点
    [Range(0.0f, 4.0f)]
	public float luminanceThreshold = 0.6f;

    void OnRenderImage(RenderTexture src, RenderTexture dest){
        if(material){
            material.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int rtW = src.width / downSample;
            int rtH = src.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(src, buffer0, material, 0); //第一个pass

            //先进行高斯模糊
            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, material, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, material, 2);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            material.SetTexture ("_Bloom", buffer0);
            //Graphics.Blit(buffer0, dest);
			Graphics.Blit (src, dest, material, 3); //再把模糊后的颜色与原颜色相加
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
