shader_type spatial;
render_mode shadows_disabled; // Add more render modes if needed

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	vec3 base_color = vec3(0.224, 0.686, 0.918);
	float basic_fresnel = fresnel(2.0, NORMAL, VIEW+vec3(0.0,0.0,0.0));
	ALBEDO = base_color;
	ALPHA = max(0, 0.5 * (0.8 - 1.0*pow(basic_fresnel*1.0, 1.0)));
}

//void light() {
	//// unshaded lighting
	//DIFFUSE_LIGHT = vec3(0.224, 0.686, 0.918);
	//// add alpha based on attenuation
	//ALPHA = min(0.6, ATTENUATION*5.0);
//}