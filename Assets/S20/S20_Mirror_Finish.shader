Shader "CG/S20_Mirror_Finish"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (0.8, 0.8, 0.8, 1)
        _Ambient ("Ambient", Range(0, 1)) = 0.2
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(1, 1024)) = 128
        _EnvCube ("Environment Cubemap", Cube) = "" {}
        _Reflectivity ("Reflectivity", Range(0, 1)) = 0.9
        _Roughness ("Roughness", Range(0, 1)) = 0
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
            float _Shininess;
            float _Reflectivity;
            float _Roughness;
            TEXTURECUBE(_EnvCube);
            SAMPLER(sampler_EnvCube);

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
                float3 L = mainLight.direction;
                float3 V = normalize(GetCameraPositionWS() - input.positionWS);
                float3 H = normalize(L + V);
                float diffuse = max(0, dot(N, L));
                float specular = pow(max(0, dot(N, H)), _Shininess);
                float3 phong = _BaseColor.rgb * (_Ambient + diffuse * mainLight.color)
                             + _SpecularColor.rgb * specular * mainLight.color;
                float3 viewReflect = reflect(-V, N);                              // 눈에서 온 시선이 표면에서 튕겨 나가는 방향
                float3 env = SAMPLE_TEXTURECUBE_LOD(_EnvCube, sampler_EnvCube, viewReflect, _Roughness * 6).rgb; // 그 방향의 주변 색
                float3 color = lerp(phong, env, _Reflectivity);                   // Phong의 색과 주변의 색을 섞음
                return float4(color, 1);
            }
            ENDHLSL
        }
        // 그림자 드리우기: Lit 셰이더의 Pass를 빌려 옴
        UsePass "Universal Render Pipeline/Lit/SHADOWCASTER"
    }
}
