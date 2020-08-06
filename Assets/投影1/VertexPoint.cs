using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class VertexPoint : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        MeshFilter mf = GetComponent<MeshFilter>();
        
        foreach(var vertex in mf.sharedMesh.vertices){
            Debug.Log(vertex);
            Debug.DrawLine(transform.position, vertex + transform.position);
        }
    }
}
