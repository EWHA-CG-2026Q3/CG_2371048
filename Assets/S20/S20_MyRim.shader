Shader "CG/S20_MyRim"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (0.8, 0.8, 0.8, 1)
        _Ambient ("Ambient", Range(0, 1)) = 0.2
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(1, 256)) = 32
        [HDR] _RimColor ("Rim Color", Color) = (0.3, 0.8, 1, 1)   // 윤곽의 색
        _RimPower ("Rim Power", Range(0.5, 8)) = 5             // 클수록 고리가 얇아짐
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
            float4 _RimColor;
            float _RimPower;

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
                float3 R = reflect(-L, N);                                        // 빛이 튕겨 나가는 방향
                float diffuse = max(0, dot(N, L));                                // 확산광의 밝기
                // pow(…, _Shininess): Shininess번 곱해, 1에 아주 가까운 자리만 밝게 남김
                float specular = pow(max(0, dot(R, V)), _Shininess);              // 반사광의 밝기
                float rim = pow(saturate(1 - dot(N, V)), _RimPower);              // 윤곽일수록 1
                float3 color = _BaseColor.rgb * (_Ambient + diffuse * mainLight.color)
                             + _SpecularColor.rgb * specular * mainLight.color
                             + _RimColor.rgb * rim;                              // 윤곽에만 색을 더함
                return float4(color, 1);
            }
            ENDHLSL
        }
        // 그림자 드리우기: Lit 셰이더의 Pass를 빌려 옴
        UsePass "Universal Render Pipeline/Lit/SHADOWCASTER"
    }
}
