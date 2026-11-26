Shader "CG/S20_PhongStep4_Diffuse"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (0.8, 0.8, 0.8, 1)
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float4 _BaseColor;

            struct Attributes                       // 메시에서 vert로 들어오는 값
            {
                float3 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings                         // vert에서 frag로 넘기는 값
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS   : TEXCOORD1;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.normalWS   = TransformObjectToWorldNormal(input.normalOS);
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float3 N = normalize(input.normalWS);
                Light mainLight = GetMainLight();
                float3 L = mainLight.direction;
                // dot(N, L): normal과 빛이 있는 쪽 사이 각도의 cos. 정면이면 1, 옆이면 0, 등지면 음수
                // max(0, …): 빛을 등진 쪽의 음수를 0으로 막음
                float diffuse = max(0, dot(N, L));                // brightness 대신 확산광의 밝기
                float3 color = _BaseColor.rgb * (0.2 + diffuse * mainLight.color);
                return float4(color, 1);
            }
            ENDHLSL
        }
    }
}
