using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class S12_PyramidMesh : MonoBehaviour
{
    void Start()
    {
        Mesh mesh = new Mesh();
        mesh.name = "S12_Pyramid";

        // Á¤Á¡ 5°³
        Vector3[] vertices =
        {
            new Vector3(-0.5f, 0f, -0.5f),  // 0: ¹Ù´Ú ¿ÞÂÊ µÚ
            new Vector3( 0.5f, 0f, -0.5f),  // 1: ¹Ù´Ú ¿À¸¥ÂÊ µÚ
            new Vector3( 0.5f, 0f,  0.5f),  // 2: ¹Ù´Ú ¿À¸¥ÂÊ ¾Õ
            new Vector3(-0.5f, 0f,  0.5f),  // 3: ¹Ù´Ú ¿ÞÂÊ ¾Õ
            new Vector3( 0f,   1f,  0f)     // 4: ²À´ë±â
        };

        // »ï°¢Çü 6°³
        int[] triangles =
        {
            // ¿·¸é 4°³
            0, 4, 1,
            1, 4, 2,
            2, 4, 3,
            3, 4, 0,

            // ¹Ù´Ú¸é 2°³
            0, 1, 2,
            0, 2, 3
        };

        mesh.vertices = vertices;
        mesh.triangles = triangles;

        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        GetComponent<MeshFilter>().mesh = mesh;
    }
}