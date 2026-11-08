using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

[InitializeOnLoad]
internal static class SetupPavilionWalkAndLights
{
    private const string ScenePath = "Assets/Scenes/TeaPavilion.unity";

    static SetupPavilionWalkAndLights()
    {
        EditorApplication.delayCall += Apply;
    }

    [MenuItem("Tools/Tea Pavilion/Apply S15 Walk and Lighting")]
    private static void Apply()
    {
        Scene scene = SceneManager.GetActiveScene();
        if (EditorApplication.isPlayingOrWillChangePlaymode || scene.path != ScenePath)
            return;

        Light sun = FindLight("Directional Light");
        if (GameObject.Find("SceneWalker") != null)
        {
            // Replace the S15 night lighting once on scenes already set up.
            if (sun != null && sun.color == Color.blue &&
                Mathf.Approximately(RenderSettings.ambientIntensity, 0.1f))
            {
                SetDaylight(sun);
                EditorSceneManager.MarkSceneDirty(scene);
                if (EditorSceneManager.SaveScene(scene))
                    Debug.Log("Tea Pavilion: daylight restored and saved.");
            }
            return;
        }

        Camera camera = Camera.main;
        GameObject lamp = GameObject.Find("Lamp_Light");
        Light point = FindLight("Point light");
        Light spot = FindLight("Point light (1)");
        Light extra = FindLight("Point light (2)");

        if (camera == null || camera.gameObject.scene != scene || lamp == null || lamp.scene != scene ||
            sun == null || point == null || spot == null || extra == null)
        {
            Debug.LogWarning("Tea Pavilion setup could not find the camera, lamp, or existing lights.");
            return;
        }

        Undo.IncrementCurrentGroup();
        int group = Undo.GetCurrentGroup();
        Undo.SetCurrentGroupName("Apply S15 walking and lighting");
        SetUpWalker(camera);

        // Keep the daytime sun and use the S15 lights under the hanging lamp.
        Undo.RecordObjects(new Object[] { point, point.transform,
            spot, spot.transform, extra }, "Apply S15 light settings");
        SetDaylight(sun);

        point.enabled = true;
        point.color = Color.white;
        point.intensity = 1f;
        point.range = 2f;
        point.shadows = LightShadows.Soft;
        point.transform.position = lamp.transform.position + Vector3.down * 0.737f;

        spot.enabled = true;
        spot.type = LightType.Spot;
        spot.color = Color.white;
        spot.intensity = 1f;
        spot.range = 5f;
        spot.spotAngle = 100.37607f;
        spot.innerSpotAngle = 21.80208f;
        spot.shadows = LightShadows.None;
        spot.transform.SetPositionAndRotation(lamp.transform.position + Vector3.down * 0.358f,
            Quaternion.Euler(90f, 0f, 0f));

        extra.enabled = false;

        Undo.CollapseUndoOperations(group);
        EditorSceneManager.MarkSceneDirty(scene);
        if (EditorSceneManager.SaveScene(scene))
            Debug.Log("Tea Pavilion: walking and daytime lighting applied and saved.");
    }

    private static void SetDaylight(Light sun)
    {
        Undo.RecordObjects(new Object[] { sun, sun.transform }, "Restore daytime lighting");
        sun.color = new Color32(255, 244, 214, 255);
        sun.intensity = 0.9f;
        sun.shadows = LightShadows.Soft;
        sun.transform.rotation = new Quaternion(0.39044842f, 0.34682903f, -0.16172905f, 0.8373192f);
        RenderSettings.ambientIntensity = 1f;
        RenderSettings.ambientSkyColor = new Color(0.212f, 0.227f, 0.259f);
    }

    private static Light FindLight(string name)
    {
        GameObject obj = GameObject.Find(name);
        return obj == null ? null : obj.GetComponent<Light>();
    }

    private static void SetUpWalker(Camera camera)
    {
        Transform view = camera.transform;
        const float eyeOffset = 0.7f;
        Vector3 start = view.position - Vector3.up * eyeOffset;
        float yaw = view.eulerAngles.y;
        var player = new GameObject("SceneWalker");
        Undo.RegisterCreatedObjectUndo(player, "Create SceneWalker");
        player.transform.SetPositionAndRotation(start, Quaternion.Euler(0f, yaw, 0f));

        CharacterController controller = Undo.AddComponent<CharacterController>(player);
        controller.height = 1.8f;
        controller.radius = 0.25f;
        controller.skinWidth = 0.03f;

        Undo.SetTransformParent(view, player.transform, "Attach camera to SceneWalker");
        SceneWalker walker = Undo.AddComponent<SceneWalker>(player);
        walker.cameraTransform = view;
    }
}
