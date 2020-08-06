using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectsBase
{
    public Shader briSatConShader;
    public Material briSatConMaterial;

    public Material material{
        get{
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }
    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f; //亮度
    [Range(0.0f, 3.0f)]
    public float stauration = 1.0f; //饱和
    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f; //对比

    void OnRenderImage(RenderTexture src, RenderTexture dest){
        if(material){
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Stauration", stauration);
            material.SetFloat("_Contrast", contrast);
            Graphics.Blit(src, dest, material);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
