using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Test : MonoBehaviour
{

    public Vector3 a;
    public Vector3 b;

    private Vector3 last;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        last = a;
        for (int i = 0; i < 11; i++)
        {
            Vector3 c = Vector3.Slerp(a, b, i * 0.1f);
            Debug.DrawLine(last, c, Color.red);
            last = c;
        }
    }
}
