using System.Runtime.CompilerServices;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase
{
    public Shader edgeShader;
    private Material edgeMaterial;

    [Range(0, 1)]
    public float edgeOnly = 0;
    public Color edgeColor = Color.black;
    public Color backGroundColor = Color.white;


    public Material material{
        get{
            edgeMaterial = CheckShaderAndCreateMaterial(edgeShader, edgeMaterial);
            return edgeMaterial;
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest){
        if(material){
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackGroundColor", backGroundColor);
            Graphics.Blit(src, dest, material);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
