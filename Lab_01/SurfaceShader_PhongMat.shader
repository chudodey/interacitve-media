shader "z/text" {

	Properties {
		_MaskTex ("Mask Texture", 2D) = "black" {}
		_EmissionMaskTex ("Emission Texture", 2D) = "black" {}
		_MainTex1 ("Main Texture 1", 2D) = "white" {}
		_MainTex2 ("Main Texture 2", 2D) = "white" {}
		_MainTex3 ("Main Texture 3", 2D) = "white" {}
		
		_EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
		
		//_VectorParam ("Vector Parameter", Vector) = (1.0, 0.5, 0.1, 0)
		
		_FloatParam ("Intensity", Float) = 7.0
		//_IntParam ("Count", Int) = 2
		
		_EmmisionAppearance ("Emission Appearance", Range(0, 1)) = 1
		
		_BumpMap ("Normal Map", 2D) = "bump" {}
		
		_Shiness1 ("Shiness 1", Range(0, 1)) = 0.07
		_Shiness2 ("Shiness 2", Range(0, 1)) = 0.07
		_Shiness3 ("Shiness 3", Range(0, 1)) = 0.07
		
		_Specularity1 ("Specularity 1", Range(0, 1)) = 0.5
		_Specularity2 ("Specularity 2", Range(0, 1)) = 0.5
		_Specularity3 ("Specularity 3", Range(0, 1)) = 0.5
		
		_SpecColor("Specular Color", Color) = (1, 1, 1, 1)
	}

	SubShader {

		CGPROGRAM
			//Lambert
			#pragma surface surf BlinnPhong
			
			sampler2D 
				_MaskTex,
				_EmissionMaskTex,
				_MainTex1,
				_MainTex2,
				_MainTex3,
				_BumpMap
			;
			
			fixed3 _EmissionColor;
			
			fixed 
				_EmmisionAppearance,
				_Specularity1,
				_Specularity2,
				_Specularity3
			;
			
			half 
				_Shiness1,
				_Shiness2,
				_Shiness3
			;
		
			struct Input {
				half2 uv_MainTex1;
				half2 uv_MaskTex;
			};
			
			void surf(Input inp, inout SurfaceOutput outp) {
				
				fixed3 masks = tex2D(_MaskTex, inp.uv_MaskTex).rgb;
				
				fixed3 color = tex2D(_MainTex1, inp.uv_MainTex1).rgb * masks.r;
				color += tex2D(_MainTex2, inp.uv_MainTex1) * masks.g;
				color += tex2D(_MainTex3, inp.uv_MainTex1) * masks.b;
				
				outp.Albedo = color;
				
				float3 emTex = tex2D(_EmissionMaskTex, inp.uv_MaskTex).rgb;
				
				half appearMask = emTex.b;
				appearMask = smoothstep(
					_EmmisionAppearance * 1.2 - 0.2, 
					_EmmisionAppearance * 1.2,
					appearMask
				);
		
				outp.Emission = appearMask * emTex.g * _EmissionColor;
				
				outp.Normal = UnpackNormal(tex2D(_BumpMap, inp.uv_MaskTex));
				
				outp.Specular = _Shiness1 * masks.r + _Shiness2 * masks.g + _Shiness3 * masks.b;
				outp.Gloss = _Specularity1 * masks.r + _Specularity2 * masks.g + _Specularity3 * masks.b;
				
			}


		ENDCG
	}

	Fallback "Diffuse"

}