shader "z/PBR-Spec" {
	
	// ShaderLab
	Properties {
		// Маска наложения текстур
		_MaskTex ("Mask Texture", 2D) = "black" {}
		
		// Маска светимости
		_EmissionMaskTex ("Emission Texture", 2D) = "black" {}
		
		// Блок текстур
		_MainTex1 ("Main Texture 1", 2D) = "white" {}
		_MainTex2 ("Main Texture 2", 2D) = "white" {}
		_MainTex3 ("Main Texture 3", 2D) = "white" {}
		
		// Цвет светимости
		_EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
		
		// Интенсивность светимости
		_FloatParam ("Intensity", Float) = 7.0
		
		// Проявление светимости от 0 до полная маски
		_EmmisionAppearance ("Emission Appearance", Range(0, 1)) = 1
		
		// Карта нормалей
		_BumpMap ("Normal Map", 2D) = "bump" {}
		
		// Яркость блика?
		_Shiness1 ("Shiness 1", Range(0, 1)) = 0.07
		_Shiness2 ("Shiness 2", Range(0, 1)) = 0.07
		_Shiness3 ("Shiness 3", Range(0, 1)) = 0.07
		
		// Размер блика?
		_Specularity1 ("Specularity 1", Range(0, 1)) = 0.5
		_Specularity2 ("Specularity 2", Range(0, 1)) = 0.5
		_Specularity3 ("Specularity 3", Range(0, 1)) = 0.5
		
		// Цвет блика
		_SpecColor("Specular Color", Color) = (1, 1, 1, 1)
	}

	SubShader {
		
		// CgFX / HLSL
		CGPROGRAM
			//Lambert BlinnPhong
			#pragma surface surf BlinnPhong
			
			// ==================================================
			// Связывание переменных HLSL с параметрами ShaderLab 
			// ==================================================
			
			// Текстуры
			sampler2D 
				_MaskTex,
				_EmissionMaskTex,
				_MainTex1,
				_MainTex2,
				_MainTex3,
				_BumpMap
			;
			
			// Вектор 3
			fixed3 _EmissionColor;
			
			// Вектор 1
			fixed 
				_EmmisionAppearance,
				_Specularity1,
				_Specularity2,
				_Specularity3
			;
			
			// Вектор 1
			half 
				_Shiness1,
				_Shiness2,
				_Shiness3
			;
			
			// Массивы UV координат для текстуры и для маски
			struct Input {
				half2 uv_MainTex1;
				half2 uv_MaskTex;
			};
			
			// Функция работы с поверхностями?
			void surf(Input inp, inout SurfaceOutput outp) {
				
				// Считываем массив пикселей из текстуры маски
				fixed3 masks = tex2D(_MaskTex, inp.uv_MaskTex).rgb;
				
				// Считываем массив пискселей из текстуры цвета 1 и закрываем красной маской
				fixed3 color = tex2D(_MainTex1, inp.uv_MainTex1).rgb * masks.r;
				// Складываем существующие пиксели с тестурой цвета 2, закрытой зелёной маской
				// * - Multuply, + - Add
				color += tex2D(_MainTex2, inp.uv_MainTex1) * masks.g;
				// Складываем существующие пиксели с текстрой цвета 3, закрытой синей маской
				color += tex2D(_MainTex3, inp.uv_MainTex1) * masks.b;
				
				// Выводим результирующий массив в параметр цвета материала
				outp.Albedo = color;
				
				// Считываем массив (вектор) пикселей из текстуры свечения
				float3 emTex = tex2D(_EmissionMaskTex, inp.uv_MaskTex).rgb;
				
				// Задаем маску-вектор из синего канала текстуры свечения
				half appearMask = emTex.b;
				
				// Связываем параметр _EmmisionAppearance со степенью раскрытия маски свечения
				// Масштабируем маску, так чтобы при 0 - маска полность была открыта, а при 1 - закрыта
				appearMask = smoothstep(
					_EmmisionAppearance * 1.2 - 0.2, 
					_EmmisionAppearance * 1.2,
					appearMask
				);
				
				// Выводим результирующее свойство свечемения материала через зеленую маску и
				// задаем цвет свечения
				outp.Emission = appearMask * emTex.g * _EmissionColor;
				
				// Выводим карту нормалей
				outp.Normal = UnpackNormal(tex2D(_BumpMap, inp.uv_MaskTex));
				
				// Выводим яркость блика?, задавая отдельные параметры для каждой из маски
				outp.Specular = _Shiness1 * masks.r + _Shiness2 * masks.g + _Shiness3 * masks.b;
				
				// Выводим размер блика, задавая отдельные параметры
				outp.Gloss = _Specularity1 * masks.r + _Specularity2 * masks.g + _Specularity3 * masks.b;
				
			}


		ENDCG
	}
	
	// Если не получилось применить шейдер, задаем стандартный материал
	Fallback "Diffuse"

}