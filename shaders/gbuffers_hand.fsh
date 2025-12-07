#version 330 compatibility

#include "/lib/dynamiclight.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;
uniform int heldBlockLightValue;
uniform int heldBlockLightValue2;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in float originalBlockLight;
flat in int itemId1;
flat in int itemId2;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	
	if (color.a < alphaTestRef) {
		discard;
	}
	
	color *= texture(lightmap, lmcoord);
	
	vec3 heldColor = getHeldLightColor(itemId1, itemId2, heldBlockLightValue, heldBlockLightValue2);
	color.rgb = applyDynamicLightTint(color.rgb, originalBlockLight, lmcoord.x, heldColor);
}