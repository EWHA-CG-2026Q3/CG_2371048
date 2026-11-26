Shader "CG/S20_Water_Finish"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _Flow ("Flow", Vector) = (0.05, 0, 0, 0)
        _Ambient ("Ambient", Range(0, 1)) = 0.2
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(1, 1024)) = 128
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

            sampler2D _BaseMap;
            float4 _Flow;
            float _Ambient;
            float4 _SpecularColor;
            float _Shininess;

            struct Attributes                       // 메시에서 vert로 들어오는 값
            {
                float3 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings                         // vert에서 frag로 넘기는 값
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS   : TEXCOORD1;
                float2 uv         : TEXCOORD2;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionWS = TransformObjectToWorld(input.positionOS);       // 위치를 월드 좌표로
                output.positionCS = TransformWorldToHClip(output.positionWS);      // 월드 좌표에서 Clip Space로
                output.normalWS   = TransformObjectToWorldNormal(input.normalOS);  // normal을 월드 좌표로
                output.uv = input.uv;
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
                float specular = pow(max(0, dot(N, H)), _Shininess);              // Blinn-Phong 하이라이트
                float2 p = input.uv + _Time.y * _Flow.xy;                         // 시간에 따라 UV를 밀어 줌
                float3 baseColor = tex2D(_BaseMap, p).rgb;                        // Base Color 대신 흐르는 텍스처의 색
                float3 color = baseColor * (_Ambient + diffuse * mainLight.color)
                             + _SpecularColor.rgb * specular * mainLight.color;
                return float4(color, 1);
            }
            ENDHLSL
        }
    }
}
