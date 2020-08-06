﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        CheckResources();
    }

    protected void CheckResources(){
        bool isSupported = CheckSupport();
        if(isSupported == false){
            NPOTSupport();
        }
    }

    protected bool CheckSupport(){
        if(SystemInfo.supportsImageEffects == false){
            return false;
        }
        return true;
    }

    protected void NPOTSupport(){
        enabled = false;
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material){
        if(shader == null){
            return null;
        }
        if(shader.isSupported && material && material.shader == shader)
            return material;
        if(!shader.isSupported){
            return null;
        }
        else{
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            return material?material:null;
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
