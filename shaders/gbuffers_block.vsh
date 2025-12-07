#version 330 compatibility

#include "/lib/dynamiclight.glsl"

uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform int heldBlockLightValue;
uniform int heldBlockLightValue2;
uniform int heldItemId;
uniform int heldItemId2;
uniform int blockEntityId;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out float originalBlockLight;
flat out int itemId1;
flat out int itemId2;
flat out int blockEntId;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	
	itemId1 = heldItemId;
	itemId2 = heldItemId2;
	blockEntId = blockEntityId;
	
	vec2 originalLmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	originalBlockLight = originalLmcoord.x;
	
	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
	vec4 playerPos = gbufferModelViewInverse * viewPos;
	float dist = length(playerPos.xyz);
	
	lmcoord = adjustLightmapWithDynamicLight(originalLmcoord, dist, heldBlockLightValue, heldBlockLightValue2);
}