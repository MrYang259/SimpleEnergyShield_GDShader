shader_type spatial;

uniform float uv_scale: hint_range(0.1, 1.0, 0.1) = 0.4;
uniform float light_strength: hint_range(0.6, 2.0, 0.1) = 0.6;
uniform float time_scale: hint_range(0.343, 1.0, 0.001) = 0.7;
uniform sampler2D noise_map: hint_default_white;

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0 / 3.0, 1.0, 1.0 / 3.0, 1.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float range(float val, float ma, float mi) {
    return val * (ma - mi) + mi;
}
void fragment() {
	vec2 p = -1.0 + 2.0 * UV;
	p *= 1.5;
	float t = cos(TIME / 30.0) * time_scale * (3.0 - cos(TIME / 9.0));
	float x = p.x / uv_scale;
	float y = p.y / uv_scale;
	float mov0 = x+y+cos(sin(t)*2.0)*100.0+sin(x/100.0)*1000.0 / uv_scale - texture(noise_map, vec2(x, y)).z;
	float mov1 = y / 0.3 + abs(t - texture(noise_map, vec2(x, y)).y);
	float mov2 = x / 0.2 + texture(noise_map, vec2(x, y - t)).x;
	float c1 = abs(sin(mov1+t)/2.0+mov2/2.0-mov1-mov2+t);
	float c2 = abs(sin(c1+sin(mov0/1000.0+t)+sin(y/40.0+t)+sin((x+y)/100.0)*3.0));
	float c3 = abs(sin(c2+cos(mov1+mov2+c2)+cos(mov2)+sin(x/1000.0)) - 0.1 * texture(noise_map, vec2(x, y + t)).z);
	vec3 col = hsv2rgb(vec3(range(c2, 0.95, 1.0), range(c3, 0.2, 1.0), range(c3, 0.25, 0.95)));
	ALBEDO = col;
	ALPHA = length(ALBEDO) * 0.3 * light_strength;
	EMISSION = col * length(col) * light_strength;
	NORMAL = ALBEDO;
}
