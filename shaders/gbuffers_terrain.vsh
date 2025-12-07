#version 330 compatibility

#include "/lib/dynamiclight.glsl"

// Uniforms provided by Iris/OptiFine
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform int heldBlockLightValue;
uniform int heldBlockLightValue2;
uniform int heldItemId;
uniform int heldItemId2;

// Block ID from block.properties (terrain only)
in vec3 mc_Entity;

// Outputs to fragment shader
out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out float originalBlockLight;
flat out int blockId;           // Block ID for emission color
flat out int itemId1;           // Pass item IDs to fragment
flat out int itemId2;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	
	blockId = int(mc_Entity.x);
	itemId1 = heldItemId;
	itemId2 = heldItemId2;
	
	vec2 originalLmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	originalBlockLight = originalLmcoord.x;
	
	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
	vec4 playerPos = gbufferModelViewInverse * viewPos;
	
	float dist = length(playerPos.xyz);
	
	lmcoord = adjustLightmapWithDynamicLight(originalLmcoord, dist, heldBlockLightValue, heldBlockLightValue2);
}