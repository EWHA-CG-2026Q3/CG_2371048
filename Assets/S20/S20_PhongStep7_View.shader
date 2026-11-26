Shader "CG/S20_PhongStep7_View"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (0.8, 0.8, 0.8, 1)
        _Ambient ("Ambient", Range(0, 1)) = 0.2
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
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
            float _Ambient;
            float4 _SpecularColor;

            struct Attributes                       // 메시에서 vert로 들어오는 값
            {
                float3 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings                         // vert에서 frag로 넘기는 값
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS   : TEXCOORD1;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionWS = TransformObjectToWorld(input.positionOS);       // 위치를 월드 좌표로
                output.positionCS = TransformWorldToHClip(output.positionWS);      // 월드 좌표에서 Clip Space로
                output.normalWS   = TransformObjectToWorldNormal(input.normalOS);  // normal을 월드 좌표로
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float3 N = normalize(input.normalWS);
                Light mainLight = GetMainLight();
                float3 L = mainLight.direction;                                   // 빛이 있는 쪽
                float3 V = normalize(GetCameraPositionWS() - input.positionWS);   // 카메라가 있는 쪽
                float diffuse = max(0, dot(N, L));                                // 확산광의 밝기
                // dot(N, V): normal과 카메라가 있는 쪽 사이 각도의 cos. 카메라를 정면으로 향하면 1
                float specular = max(0, dot(N, V));                               // 반사광의 밝기 (임시)
                float3 color = _BaseColor.rgb * (_Ambient + diffuse * mainLight.color)
                             + _SpecularColor.rgb * specular * mainLight.color;
                return float4(color, 1);
            }
            ENDHLSL
        }
    }
}
