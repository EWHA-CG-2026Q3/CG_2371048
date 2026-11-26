Shader "CG/S20_PhongStep2_Normal"
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
            
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
                float brightness = 1;                             // 고칠 줄: 그 픽셀의 밝기
                // 실험: ① 1  ② N.y  ③ N.x  ④ dot(N, normalize(float3(1, 1, 0)))
                //       ⑤ 0.2 + dot(N, normalize(float3(1, 1, 0)))
                //       ⑥ 0.2 + max(0, dot(N, normalize(float3(1, 1, 0))))  ⑦ ⑥ 그대로 Directional Light 돌려 보기
                float3 color = _BaseColor.rgb * brightness;
                return float4(color, 1);
            }
            ENDHLSL
        }
    }
}
