Shader "CG/S20_Outline_Finish"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.02
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass
        {
            Tags { "LightMode" = "SRPDefaultUnlit" }
            Cull Front                              // 앞면은 그리지 않고 뒷면만 그림
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _OutlineColor;
            float _OutlineWidth;

            struct Attributes                       // 메시에서 vert로 들어오는 값
            {
                float3 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings                         // vert에서 frag로 넘기는 값
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                float3 pushed = input.positionOS + input.normalOS * _OutlineWidth;  // normal 방향으로 밀어 부풀림
                output.positionCS = TransformObjectToHClip(pushed);
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                return float4(_OutlineColor.rgb, 1);                               // 검정 하나로 칠함
            }
            ENDHLSL
        }
    }
}
