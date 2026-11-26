// S23 과제 5: S20의 툰(S20_Toon_Finish) + 외곽선(S20_Outline_Finish) + 정점 색(S20_VertexColor_Finish)을
// 하나의 셰이더(Pass 2개, 재질 칸 1개)로 합침
// - Pass ①: 정점 색을 Base Color 대신 쓰고, 확산광을 몇 단계로 끊어 툰 명암을 만듦
// - Pass ②: 정점을 normal 방향으로 부풀린 뒷면을 한 가지 색으로 그려 외곽선을 만듦
Shader "CG/S23_ToonOutlineVertexColor"
{
    Properties
    {
        _BaseColor ("Tint", Color) = (1, 1, 1, 1)            // 정점 색에 곱하는 색 (흰색이면 정점 색 그대로)
        _Ambient ("Ambient", Range(0, 1)) = 0.2
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(1, 256)) = 32
        _ToonSteps ("Toon Steps", Range(1, 8)) = 3
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.02
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        // ① 툰 + 정점 색
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
            float _Shininess;
            float _ToonSteps;

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 color      : COLOR;                   // 메시의 정점 색 (VertexColor에서 가져옴)
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS   : TEXCOORD1;
                float4 color      : TEXCOORD2;               // 정점 색을 frag로 넘김
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.positionCS = TransformWorldToHClip(output.positionWS);
                output.normalWS   = TransformObjectToWorldNormal(input.normalOS);
                output.color      = input.color;
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float3 N = normalize(input.normalWS);
                Light mainLight = GetMainLight();
                float3 L = mainLight.direction;
                float3 V = normalize(GetCameraPositionWS() - input.positionWS);
                float3 R = reflect(-L, N);

                float diffuse = max(0, dot(N, L));
                diffuse = floor(diffuse * _ToonSteps) / _ToonSteps;        // 툰: 명암을 몇 단계로 끊음 (Toon에서 가져옴)

                float specular = pow(max(0, dot(R, V)), _Shininess);

                float3 surfaceColor = input.color.rgb * _BaseColor.rgb;    // 정점 색을 표면 색으로 (VertexColor에서 가져옴)

                float3 color = surfaceColor * (_Ambient + diffuse * mainLight.color)
                             + _SpecularColor.rgb * specular * mainLight.color;
                return float4(color, 1);
            }
            ENDHLSL
        }

        // ② 외곽선 (Outline에서 가져옴)
        Pass
        {
            Name "Outline"
            Tags { "LightMode" = "SRPDefaultUnlit" }
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _OutlineColor;
            float _OutlineWidth;

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                float3 pushed = input.positionOS + input.normalOS * _OutlineWidth;
                output.positionCS = TransformObjectToHClip(pushed);
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                return _OutlineColor;
            }
            ENDHLSL
        }

        // 그림자 드리우기: Lit 셰이더의 Pass를 빌려 옴
        UsePass "Universal Render Pipeline/Lit/SHADOWCASTER"
    }
}
