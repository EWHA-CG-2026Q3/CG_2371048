using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(DiamondMesh))]
public class Shear : MonoBehaviour
{
    public float k = 1.8f;

    DiamondMesh diamond;

    void OnValidate()
    {
        diamond = GetComponent<DiamondMesh>();

        if (diamond != null)
        {
            ApplyShear();

            Vector3 top = diamond.BaseVertices[5];
            Vector4 h = ToHomogeneous(top);
            Vector4 result = MultiplyMatrixVector4x4(ShearMatrixRaw(k), h);

            Debug.Log("Top Vertex: " + FromHomogeneous(result));
        }
    }

    void Update()
    {
        if (diamond == null)
            diamond = GetComponent<DiamondMesh>();

        if (diamond != null)
            ApplyShear();
    }
    void ApplyShear()
    {
        Vector3[] baseVertices = diamond.BaseVertices;
        Vector3[] verts = new Vector3[baseVertices.Length];

        float[,] H = ShearMatrixRaw(k);

        for (int i = 0; i < baseVertices.Length; i++)
        {
            Vector4 h = ToHomogeneous(baseVertices[i]);
            Vector4 result = MultiplyMatrixVector4x4(H, h);
            verts[i] = FromHomogeneous(result);
        }

        diamond.SetVertices(verts);
    }

    float[,] ShearMatrixRaw(float k)
    {
        return new float[,]
        {
            { 1f,  k, 0f, 0f },
            { 0f, 1f, 0f, 0f },
            { 0f, 0f, 1f, 0f },
            { 0f, 0f, 0f, 1f }
        };
    }

    Vector4 ToHomogeneous(Vector3 v)
    {
        return new Vector4(v.x, v.y, v.z, 1f);
    }

    Vector3 FromHomogeneous(Vector4 h)
    {
        return new Vector3(h.x, h.y, h.z);
    }

    Vector4 MultiplyMatrixVector4x4(float[,] A, Vector4 v)
    {
        float[] input = { v.x, v.y, v.z, v.w };
        float[] output = new float[4];

        for (int row = 0; row < 4; row++)
        {
            for (int col = 0; col < 4; col++)
            {
                output[row] += A[row, col] * input[col];
            }
        }

        return new Vector4(
            output[0],
            output[1],
            output[2],
            output[3]
        );
    }
}