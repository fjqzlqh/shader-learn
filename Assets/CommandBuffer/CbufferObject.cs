using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
 
public class CbufferObject : MonoBehaviour
{
    private MeshRenderer render;
    private Material material;
 
    private CommandBuffer cmdBuffer;
 
    private void Awake()
    {
        render = GetComponent<MeshRenderer>();
        material = new Material(Shader.Find("CmdBuffer/PureColorShader"));
        material.SetColor("_MainColor", Color.red);
    }
 
    void Start()
    {
        
    }
 
    private void OnEnable()
    {
        cmdBuffer = new CommandBuffer();
        cmdBuffer.DrawRenderer(render, material);
        Camera.main.AddCommandBuffer(CameraEvent.AfterEverything, cmdBuffer);
    }
 
    private void OnDisable()
    {
        if (Camera.main != null)
        {
            Camera.main.RemoveCommandBuffer(CameraEvent.AfterImageEffects, cmdBuffer);
        }
    }
}
