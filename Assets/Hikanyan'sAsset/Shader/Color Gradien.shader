Shader "Custom/Color Gradient"
{
	Properties
	{
		_Dsitance("Distance", float) = 3.0
		_FarColor("Far Color", Color) = (0, 0, 0, 1)
		_NearColor("Near Color", Color) = (1, 1, 1, 1)
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _Dsitance;
			fixed4 _FarColor;
			fixed4 _NearColor;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex); // ���[�J�����W�n�����[���h���W�n�ɕϊ�
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// �J�����ƃI�u�W�F�N�g�̋���(����)���擾
				float dist = length(_WorldSpaceCameraPos - i.worldPos);
			// Lerp(���`���)���g���ĐF��ω�
			fixed4 col = fixed4(lerp(_NearColor.rgb, _FarColor.rgb, dist / _Dsitance), 1);
			return col;
		}
		ENDCG
	}
	}
}