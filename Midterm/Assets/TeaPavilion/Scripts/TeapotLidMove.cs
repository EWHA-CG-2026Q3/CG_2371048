using UnityEngine;

// Keep this component on TeapotLid. Its parent is the teapot body.
public class TeapotLidMove : MonoBehaviour
{
    private Transform teapot;
    private Vector3 restingPosition;
    private Quaternion restingRotation;
    private Vector3 tiltAxis;

    private void Start()
    {
        teapot = transform.parent;
        GameObject cup = GameObject.Find("TeaCup2");
        if (teapot == null || cup == null)
        {
            enabled = false;
            return;
        }

        restingPosition = teapot.position;
        restingRotation = teapot.rotation;

        Vector3 towardCup = cup.transform.position - restingPosition;
        towardCup.y = 0f;
        tiltAxis = Vector3.Cross(Vector3.up, towardCup).normalized;
    }

    private void Update()
    {
        // 6초마다 잠시 쉬고, 4초 동안 기울였다가 돌아온다.
        float phase = Mathf.Clamp01((Time.timeSinceLevelLoad % 6f - 1f) / 4f);
        float pour = Mathf.Sin(Mathf.PI * phase);
        float angle = 32f * pour;
        Vector3 position = restingPosition + Vector3.up * (0.10f * pour);
        Quaternion rotation = Quaternion.AngleAxis(angle, tiltAxis) * restingRotation;

        // S10 실습처럼 이동과 회전 행렬을 따로 만든 뒤 합친다.
        Matrix4x4 T = Matrix4x4.Translate(position);
        Matrix4x4 R = Matrix4x4.Rotate(rotation);
        Matrix4x4 M = T * R;

        // 원점은 주전자의 위치, 앞과 위 방향은 주전자의 회전을 정한다.
        teapot.position = M.MultiplyPoint(Vector3.zero);
        Vector3 forward = M.MultiplyVector(Vector3.forward);
        Vector3 up = M.MultiplyVector(Vector3.up);
        teapot.rotation = Quaternion.LookRotation(forward, up);
    }
}
