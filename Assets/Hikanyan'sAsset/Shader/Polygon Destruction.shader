Shader "Custom/Polygon Destruction"
{
	Properties
	{
		_FarColor("Far Color", Color) = (1, 1, 1, 1)
		_NearColor("Near Color", Color) = (0, 0, 0, 1)
		_Texture("Select Texture",2D) = "White"{}
		_ScaleFactor("Scale Factor", float) = 0.5
		_StartDistance("Start Distance", float) = 3.0
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			fixed4 _FarColor;
			fixed4 _NearColor;
			fixed _ScaleFactor;
			fixed _StartDistance;
			fixed4 _Texture;
			struct Input {
				float2 uv_MainTex;
			};
			sampler2D _MainTex;
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct g2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			// �����_���Ȓl��Ԃ�
			float rand(float2 seed)
			{
				return frac(sin(dot(seed.xy, float2(13.000, 70.000))) * 40000.000);
			}

			appdata vert(appdata v)
			{
				return v;
			}

			// �W�I���g���V�F�[�_�[
			[maxvertexcount(3)]
			void geom(triangle appdata input[3], inout TriangleStream<g2f> stream)
			{
				// �J�����ƃ|���S���̏d�S�̋���
				float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
				float4 worldPos = mul(unity_ObjectToWorld, float4(center, 1.0));
				float3 dist = length(_WorldSpaceCameraPos - worldPos);

				// �@�����v�Z
				float3 vec1 = input[1].vertex - input[0].vertex;
				float3 vec2 = input[2].vertex - input[0].vertex;
				float3 normal = normalize(cross(vec1, vec2));

				// �J�����Ƃ̋����ɂ���ă|���S��������ω�
				fixed destruction = clamp(_StartDistance - dist, 0.0, 1.0);
				// �J�����Ƃ̋����ɂ���ĐF��ω�
				fixed gradient = clamp(dist - _StartDistance, 0.0, 1.0);

				fixed random = rand(center.xy);
				fixed3 random3 = random.xxx;

				[unroll]
				for (int i = 0; i < 3; i++)
				{
					appdata v = input[i];
					g2f o;
					// �@���x�N�g���ɉ����Ē��_���ړ�
					v.vertex.xyz += normal * destruction * _ScaleFactor * random3;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					// Lerp(���`���)���g���ĐF��ω�
					o.color = fixed4(lerp(_NearColor.rgb, _FarColor.rgb, gradient), 1);
					stream.Append(o);
				}
				stream.RestartStrip();
			}

			fixed4 frag(g2f i) : SV_Target
			{
				fixed4 col = i.color;
				return col;
			}

			ENDCG
		}
	}
		FallBack "Unlit/Color"
}