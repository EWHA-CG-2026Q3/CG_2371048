using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public sealed class TeaCupMesh : MonoBehaviour
{
    private const int Segments = 50;

    // (반지름, 높이)
    private static readonly Vector2[] Profile =
    {
        new Vector2(0.25f, -0.5000f),
        new Vector2(0.30f, -0.5000f),
        new Vector2(0.35f, -0.4700f),
        new Vector2(0.35f, -0.4300f),
        new Vector2(0.45f, -0.3700f),
        new Vector2(0.50f, -0.3000f),
        new Vector2(0.60f, -0.1700f),
        new Vector2(0.65f, -0.0300f),
        new Vector2(0.70f,  0.1300f),
        new Vector2(0.75f,  0.2500f),
        new Vector2(0.73f,  0.2700f),
        new Vector2(0.70f,  0.2700f),
        new Vector2(0.67f,  0.2500f),
        new Vector2(0.65f,  0.1300f),
        new Vector2(0.60f, -0.0300f),
        new Vector2(0.50f, -0.1700f),
        new Vector2(0.40f, -0.2700f),
        new Vector2(0.30f, -0.3300f),
        new Vector2(0.15f, -0.3300f)
    };

    private Mesh generatedMesh;
    private Mesh previousMesh;

    private void OnEnable()
    {
        int ringVertexCount = Profile.Length * Segments;
        int bottomCenter = ringVertexCount;
        int insideCenter = ringVertexCount + 1;
        int lastRing = ringVertexCount - Segments;
        Vector3[] vertices = new Vector3[ringVertexCount + 2];
        int[] triangles = new int[Profile.Length * Segments * 6];

        // 1. 각 높이에서 원 둘레에 정점을 만든다.
        for (int ring = 0; ring < Profile.Length; ring++)
        {
            Vector2 point = Profile[ring];
            for (int segment = 0; segment < Segments; segment++)
            {
                float angle = 2f * Mathf.PI * segment / Segments;
                vertices[ring * Segments + segment] = new Vector3(
                    point.x * Mathf.Cos(angle), point.y, point.x * Mathf.Sin(angle));
            }
        }

        vertices[bottomCenter] = Vector3.up * Profile[0].y;
        vertices[insideCenter] = Vector3.up * Profile[Profile.Length - 1].y;

        // 2. 이웃한 원의 네 점을 두 삼각형으로 잇는다.
        int index = 0;
        for (int ring = 0; ring < Profile.Length - 1; ring++)
        {
            for (int segment = 0; segment < Segments; segment++)
            {
                int nextSegment = (segment + 1) % Segments;
                int a = ring * Segments + segment;
                int b = ring * Segments + nextSegment;
                int c = (ring + 1) * Segments + segment;
                int d = (ring + 1) * Segments + nextSegment;

                triangles[index++] = a;
                triangles[index++] = c;
                triangles[index++] = b;
                triangles[index++] = b;
                triangles[index++] = c;
                triangles[index++] = d;
            }
        }

        // 3. 중심점에 연결해 밑면과 안쪽 바닥을 닫는다.
        for (int segment = 0; segment < Segments; segment++)
        {
            int next = (segment + 1) % Segments;
            triangles[index++] = bottomCenter;
            triangles[index++] = segment;
            triangles[index++] = next;
            triangles[index++] = insideCenter;
            triangles[index++] = lastRing + next;
            triangles[index++] = lastRing + segment;
        }

        // 4. 다이아몬드 실습처럼 배열을 Mesh에 넣는다.
        Mesh mesh = new Mesh { name = "Tea Cup", hideFlags = HideFlags.DontSave };
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
        MeshFilter filter = GetComponent<MeshFilter>();
        previousMesh = filter.sharedMesh;
        generatedMesh = mesh;
        filter.sharedMesh = mesh;
    }

    private void OnDisable()
    {
        if (generatedMesh == null)
            return;

        MeshFilter filter = GetComponent<MeshFilter>();
        if (filter != null && filter.sharedMesh == generatedMesh)
            filter.sharedMesh = previousMesh;

        if (Application.IsPlaying(gameObject))
            Destroy(generatedMesh);
        else
            DestroyImmediate(generatedMesh);

        generatedMesh = null;
    }
}
