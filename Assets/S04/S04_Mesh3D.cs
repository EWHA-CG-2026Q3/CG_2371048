using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class S04_Mesh3D : MonoBehaviour
{
    void Start()
    {
        Vector3[] vertices = new Vector3[]
        {
            new Vector3(0.5f, 0f, 0.5f), // 0
            new Vector3(0f, 1f, 0f), // 1
            new Vector3(1f, 1f, 0f), // 2
            new Vector3(1f, 1f, 1f), // 3
            new Vector3(0f, 1f, 1f), // 4
            new Vector3(0.5f, 2f, 0.5f) // 5
        };

        int[] triangles = new int[]
        {
            1, 5, 2,
            2, 5, 3,
            3, 5, 4,
            4, 5, 1,
            1, 2, 0,
            2, 3, 0,
            3, 4, 0,
            4, 1, 0,

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
