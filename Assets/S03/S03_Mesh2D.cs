using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class S03_ : MonoBehaviour
{
    void Start()
    {
        Vector3[] vertices = new Vector3[]
        {
              new Vector3(0f, 1f, 0f), // 0
              new Vector3(1.732f, 0f, 0f), // 1
              new Vector3(3.464f, 1f, 0f), // 2
              new Vector3(3.464f, 2.732f, 0f), // 3
              new Vector3(1.732f, 3.732f, 0f), // 4
              new Vector3(0f, 2.732f, 0f), // 5

        };
        int[] triangles = new int[]
        {
            0, 1, 2,
            0, 2, 3,
            0, 3, 4,
            0, 4, 5
        };


        Mesh mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();

        GetComponent<MeshFilter>().mesh = mesh;
        MeshRenderer meshRenderer = GetComponent<MeshRenderer>();

        if (meshRenderer.sharedMaterial == null)
        {
            meshRenderer.sharedMaterial = new Material(Shader.Find("Universal Render Pipeline/Lit"));
        }
    }
}
