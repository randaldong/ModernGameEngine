struct SpecularGlossiness 
{
	float3 specular;
	float3 diffuse;
	float3 normal;
	float glossiness;
};

SpecularGlossiness getPBRParameterSG()
{
	SpecularGlossiness specular_glossiness;
	specular_glossiness.diffuse = sampleTexture(diffuse_texture, uv).rgb;
	specular_glossiness.specular = sampleTexture(specular_texture, uv).rgb;
	specular_glossiness.normal = sampleTexture(normal_texture, uv).rgb;
	specular_glossiness.glossiness = sampleTexture(gloss_texture, uv).r;
	return specular_glossiness;
}

float3 calculateBRDF(SpecularGlossiness specular_glossiness)
{
	float3 half_vector = normalize(view_direction + light_direction);
	float N_dot_L = saturate(dot(specular_glossiness.normal, light_direction));
	float N_dot_V = abs(dot(specular_glossiness.normal, view_direction));
	float3 N_dot_H = saturate(dot(specular_glossiness.normal, half_vector));
	float3 V_dot_H = saturate(dot(view_direction, half_vector));

	// diffuse
	float3 diffuse = k_d * specular_glossiness / PI;

	// specular
	float roughness = 1.0 - specular_glossiness.glossiness;
	float3 F0 = specular_glossiness.specular;

	float D = D_GGX(N_dot_H, roughness);
	float3 F = F_Schlick(V_dot_H, F0);
	float G = G_Smith(N_dot_V, N_dot_L, roughness);
	float denominator = 4.0 * N_dot_V * N_dot_L + 0.001;

	float3 specular = (D * F * G) / denominator;

	// brdf
	return diffuse + specular;
}

float3 PixelShaderSG()
{
	SpecularGlossiness specular_glossiness = getPBRParameterSG();
	float3 brdf_reflection = calculateBRDF(specular_glossiness);
	return brdf_reflection * light_intensity * cos(light_incident_angle);
}

