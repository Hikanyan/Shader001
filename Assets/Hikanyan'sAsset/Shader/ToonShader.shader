Shader "Hikanyan/toon" {
    // �v���p�e�B
    Properties{
        // �x�[�X�ƂȂ�F
        _Color("Color", Color) = (1, 1, 1, 1)
        // ���C���e�N�X�`��
        _MainTex("Albedo(RGB)", 2D) = "white" {}
    // ramp�e�N�X�`��
    _RampTex("Ramp", 2D) = "white" {}
    }

        // Shader�̒��g���L�q
        SubShader{
        // ��ʓI��Shader���g�p
        Tags {"RenderType" = "Opaque"}
        // �������l
        LOD 200

        // cg����L�q
        CGPROGRAM
        // ���\�b�h����LightingToonRamp�̃J�X�^�����C�e�B���O�錾
        #pragma surface surf ToonRamp
        // Shader Model
        #pragma target 3.0

        // ���C���e�N�X�`��
        sampler2D _MainTex;
    // ramp�e�N�X�`��
    sampler2D _RampTex;

    // input�\����
    struct Input {
        // uv���W
        float2 uv_MainTex;
    };

    // �x�[�X�ƂȂ�F
    fixed4 _Color;

    // �J�X�^�����C�e�B���O
    fixed4 LightingToonRamp(SurfaceOutput s, fixed3 lightDir, fixed atten) {
        // ���ς��擾
        half diff = dot(s.Normal, lightDir);
        // ramp�e�N�X�`����uv�l���擾
        fixed3 ramp = tex2D(_RampTex, fixed2(diff, diff)).rgb;
        // ramp�e�N�X�`����uv�l����F���擾
        fixed4 c;
        c.rgb = s.Albedo * _LightColor0.rgb * ramp * atten;
        c.a = s.Alpha;
        return c;
    }

    // surf�֐�
    void surf(Input IN, inout SurfaceOutput o) {
        fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
        o.Albedo = c.rgb;
        o.Alpha = c.a;
    }
    // Shader�̋L�q�I��
    ENDCG
    }
        // SubShader�����s�������ɌĂ΂��
        Fallback "Diffuse"
}