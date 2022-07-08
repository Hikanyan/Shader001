// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Pixel�����ŃV�F�[�f�B���O�v�Z���s��ToonShader
Shader "Custom/ToonShader" {
	// ToonShader�̃p�����[�^��錾
	Properties{
		// ��ԈÂ��F�̎w��
		_Ambient("Ambient Color", Color) = (0.1,0.1, 0.4,1)
		// �g�U���˂Ő��䂳���A�e�̈�(�A�e�̖��邢����)
		// Border: �A�e�̈�̋��E�𐧌�
		// BorderBlur: �A�e�̈�̋��E�̂ڂ���̐���
		_Diffuse("Diffuse Color", Color) = (0.3,0.3,1,1)
		_DiffuseBorder("Diffuse border", Range(0.01, 1)) = 0.2
		_DiffuseBorderBlur("Diffuse border blur", Range(0.01, 0.2)) = 0.01
		// ���ʔ��˂Ő��䂳���A�e�̈�(�n�C���C�g����)
		// Border: �A�e�̈�̋��E�𐧌�
		// BorderBlur: �A�e�̈�̋��E�̂ڂ���̐���
		_Specular("Spec Color", Color) = (1,1,1,1)
		_SpecularBorder("Specular border", Range(0.01, 1)) = 0.5
		_SpecularBorderBlur("Specular border blur", Range(0.01, 0.2)) = 0.01
		_Shininess("Shininess", Range(0.01, 1)) = 0.7
	}
		SubShader{
		pass {
		// Unity�̃��C�g�I�u�W�F�N�g���g����LightMode
		Tags { "LightMode" = "ForwardBase" }
			// Cg�v���O�������g�p����錾
			// ���_�����ƃs�N�Z���������s�����Ƃ�錾
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			// Cg�v���O�����Ŏg���ϐ�
			// Properties�u���b�N�ƑΉ��t����
			float4	_Ambient;
			float4	_Diffuse;
			float 	_DiffuseBorder;
			float 	_DiffuseBorderBlur;
			float4	_Specular;
			float 	_SpecularBorder;
			float 	_SpecularBorderBlur;
			float _Shininess;
			// ���_����s�N�Z���ɓ]�������f�[�^
			struct vertexOutput {
				float4 pos : SV_POSITION; // ���W�ϊ���̈ʒu
				float3 L   : TEXCOORD0; // ���C�g�x�N�g��
				float3 N   : TEXCOORD1; // �@���x�N�g��
				float3 RV   : TEXCOORD2; // �����̐����˃x�N�g��
			};
			// ���_���̏���
			// pos, L, N, RV�̃f�[�^���v�Z����D
			vertexOutput vert(appdata_base v) : POSITION
			{
				vertexOutput output;
			// ���W�ϊ���̈ʒu
			output.pos = UnityObjectToClipPos(v.vertex);
			// �@���x�N�g��
			float3 N = v.normal;
			output.N = N;
			// ���C�g�x�N�g��
			output.L = ObjSpaceLightDir(v.vertex);
			// �����̐����˃x�N�g��
			float3 V = ObjSpaceViewDir(v.vertex);
			output.RV = reflect(-V, N);
			return output;
		}
				// �s�N�Z�����̏���
				// 1. �ʏ�̕����I�ȃ��C�e�B���O�v�Z���s��
				// 2. �Ɩ����ʂ���Ɍ��F�������s��
				float4 frag(vertexOutput input) : COLOR
				{
			// ���_�����Ōv�Z�����x�N�g���f�[�^�𐳋K�����Ď��o��
			float3 L = normalize(input.L);
			float3 N = normalize(input.N);
			float3 RV = normalize(input.RV);
			// �g�U���˂̓x��I_d���v�Z
			float LdN = clamp(dot(L, N), 0, 1);
			float I_d = LdN;
			// ���ʔ��˂̓x��I_s���v�Z
			float LdRV = clamp(dot(L, RV), 0, 1);
			float shininess = pow(500.0, _Shininess);
			float I_s = pow(LdRV, shininess);
			// ����ꂽI_d, I_s����Ɍ��F�������s��
			// ��ԈÂ��F����X�^�[�g����
			float4 c_a = _Ambient;
			// �g�U���˂̓x��I_d�����臒l�������s���C
			// I_d > _DiffuseBorder�ł���΁C_Diffuse�̐F�œh��
			// _DiffuseBorderBlur�ɂ��C���E�����̂ڂ���𐧌䂵�Ă���
			float t_d = smoothstep(_DiffuseBorder - _DiffuseBorderBlur, _DiffuseBorder + _DiffuseBorderBlur, I_d);
			float4 c_d = lerp(c_a, _Diffuse, t_d);
			// �g�U���˂Ɠ��l�ɁC���ʔ��˂ɂ��Ă�臒l�������s��
			float t_s = smoothstep(_SpecularBorder - _SpecularBorderBlur, _SpecularBorder + _SpecularBorderBlur, I_s);
			float4 c = lerp(c_d, _Specular, t_s);
			return c;
		}
		ENDCG
		}
	}
		FallBack "Diffuse"
}