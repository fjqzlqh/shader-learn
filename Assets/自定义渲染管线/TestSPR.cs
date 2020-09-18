using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestSPR : MonoBehaviour
{
    public RenderTexture rt;
    public Transform[] cubeTransforms;
    public MeshFilter cubeMesh;
    public Material pureColorMaterial;

    // Start is called before the first frame update
    void Start()
    {
        rt = new RenderTexture(Screen.width, Screen.height, 24);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnPostRender()
    {
        Camera camera = Camera.current;
        Graphics.SetRenderTarget(rt);
        GL.Clear(true, true, Color.gray);
        //start drawcall
        pureColorMaterial.color = new Color(0, 0.5f, 0.8f);
        pureColorMaterial.SetPass(0);
        foreach(var i in cubeTransforms)
        {
            Graphics.DrawMeshNow(cubeMesh.mesh, i.localToWorldMatrix);
        }
        
        //end drawcall
        Graphics.Blit(rt, camera.targetTexture);
    }
}
