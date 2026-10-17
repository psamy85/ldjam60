shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform float curvature : hint_range(0.0, 0.5) = 0.015;
uniform float scanline_count = 60.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.35;
uniform float aberration : hint_range(0.0, 0.01) = 0.003;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.3;
uniform float flicker_intensity : hint_range(0.0, 0.1) = 0.02;
uniform float brightness : hint_range(0.5, 2.0) = 1.2;

vec2 curve(vec2 uv) {
	uv = uv * 2.0 - 1.0;
	vec2 offset = uv.yx * uv.yx * curvature;
	uv += uv * offset;
	return uv * 0.5 + 0.5;
}

void fragment() {
	// Courbure calculée dans le repère du ColorRect (0..1 sur sa surface)
	vec2 uv = curve(UV);

	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		// Conversion du repère du ColorRect vers le repère de l'écran
		vec2 scale = vec2(dFdx(SCREEN_UV.x) / dFdx(UV.x), dFdy(SCREEN_UV.y) / dFdy(UV.y));
		vec2 screen_uv = SCREEN_UV + (uv - UV) * scale;

		// Aberration chromatique
		float r = texture(screen_texture, screen_uv + vec2(aberration, 0.0)).r;
		float g = texture(screen_texture, screen_uv).g;
		float b = texture(screen_texture, screen_uv - vec2(aberration, 0.0)).b;
		vec3 col = vec3(r, g, b);

		// Scanlines
		float s = sin(uv.y * scanline_count * TAU) * 0.5 + 0.5;
		col *= 1.0 - scanline_intensity * s;

		// Vignette
		float vig = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
		col *= clamp(pow(16.0 * vig, vignette_intensity), 0.0, 1.0);

		// Scintillement
		col *= 1.0 - flicker_intensity * (sin(TIME * 110.0) * 0.5 + 0.5);

		COLOR = vec4(col * brightness, 1.0);
	}
}