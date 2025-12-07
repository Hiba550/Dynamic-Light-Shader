//lib
//quillphen
//GNU Affero General Public License v3.0
//https://www.gnu.org/licenses/agpl-3.0.en.html
//lol if you read this you are cool
//goto gbuffers_terrain.fsh
#ifndef DYNAMIC_LIGHT_GLSL
#define DYNAMIC_LIGHT_GLSL

#ifndef DYNAMIC_LIGHT_INTENSITY
    #define DYNAMIC_LIGHT_INTENSITY 1.0
#endif

//(0.0 = no tint, 1.0 = full color)
#ifndef DYNAMIC_LIGHT_COLOR_INTENSITY
    #define DYNAMIC_LIGHT_COLOR_INTENSITY 0.6
#endif


const vec3 COLOR_TORCH       = vec3(1.0, 0.7, 0.4);      // Orange flame
const vec3 COLOR_SOUL        = vec3(0.3, 0.8, 0.9);      // Cyan soul flame
const vec3 COLOR_LANTERN     = vec3(1.0, 0.85, 0.6);     // Golden lantern
const vec3 COLOR_LAVA        = vec3(1.0, 0.4, 0.1);      // Deep orange-red
const vec3 COLOR_FIRE        = vec3(1.0, 0.6, 0.2);      // Orange fire
const vec3 COLOR_FURNACE     = vec3(1.0, 0.55, 0.2);     // Furnace glow
const vec3 COLOR_JACK        = vec3(1.0, 0.65, 0.2);     // Pumpkin orange
const vec3 COLOR_SHROOMLIGHT = vec3(1.0, 0.75, 0.5);     // Warm yellow-orange
const vec3 COLOR_CRYING_OBS  = vec3(0.7, 0.3, 0.9);      // Purple tears
const vec3 COLOR_CANDLE      = vec3(1.0, 0.8, 0.5);      // Warm candlelight
const vec3 COLOR_BLAZE       = vec3(1.0, 0.5, 0.1);      // Blaze orange
const vec3 COLOR_SEA_LANTERN = vec3(0.5, 0.9, 1.0);      // Aqua/cyan
const vec3 COLOR_CONDUIT     = vec3(0.3, 0.7, 1.0);      // Blue
const vec3 COLOR_BEACON      = vec3(0.9, 0.95, 1.0);     // White-blue
const vec3 COLOR_SCULK       = vec3(0.1, 0.4, 0.7);      // Deep blue
const vec3 COLOR_VERDANT     = vec3(0.4, 0.9, 0.6);      // Cyan-green froglight
const vec3 COLOR_HEART_SEA   = vec3(0.2, 0.5, 1.0);      // Deep ocean blue
const vec3 COLOR_GLOW_INK    = vec3(0.3, 0.9, 0.9);      // Glow squid cyan
const vec3 COLOR_NETHER_STAR = vec3(0.95, 0.98, 1.0);    // Bright white-blue
const vec3 COLOR_GLOW_LICHEN = vec3(0.5, 0.8, 0.4);      // Soft green
const vec3 COLOR_GLOW_BERRY  = vec3(1.0, 0.75, 0.3);     // Warm gold-green
const vec3 COLOR_OCHRE       = vec3(0.9, 0.8, 0.3);      // Yellow-green froglight
const vec3 COLOR_XP_BOTTLE   = vec3(0.4, 1.0, 0.4);      // Bright green
const vec3 COLOR_END_ROD     = vec3(0.9, 0.8, 1.0);      // Soft purple-white
const vec3 COLOR_ENDER       = vec3(0.5, 0.2, 0.8);      // Deep purple
const vec3 COLOR_AMETHYST    = vec3(0.7, 0.4, 0.9);      // Purple crystal
const vec3 COLOR_DRAGON      = vec3(0.8, 0.3, 0.9);      // Magenta
const vec3 COLOR_PEARLESCENT = vec3(0.9, 0.5, 0.8);      // Pink-purple froglight
const vec3 COLOR_PORTAL      = vec3(0.6, 0.2, 0.9);      // Portal purple
const vec3 COLOR_RESPAWN     = vec3(0.9, 0.3, 0.5);      // Respawn anchor
const vec3 COLOR_REDSTONE    = vec3(0.9, 0.1, 0.1);      // Red
const vec3 COLOR_RS_LAMP     = vec3(1.0, 0.7, 0.5);      // Warm red-orange
const vec3 COLOR_MAGMA       = vec3(0.9, 0.3, 0.1);      // Red-orange
const vec3 COLOR_GLOWSTONE   = vec3(1.0, 0.9, 0.7);      // Warm white
const vec3 COLOR_WHITE       = vec3(1.0, 1.0, 1.0);      // Pure white
const vec3 COLOR_COPPER      = vec3(1.0, 0.7, 0.5);      // Copper orange
const vec3 COLOR_DEFAULT     = vec3(1.0, 0.85, 0.7);     // Warm white default
//colid
vec3 getLightColorFromItemId(int itemId) {
    if (itemId == 100) return COLOR_TORCH;           // Torch
    if (itemId == 101) return COLOR_SOUL;            // Soul Torch
    if (itemId == 102) return COLOR_LANTERN;         // Lantern
    if (itemId == 103) return COLOR_SOUL;            // Soul Lantern
    if (itemId == 104) return COLOR_FIRE;            // Campfire
    if (itemId == 105) return COLOR_SOUL;            // Soul Campfire
    if (itemId == 106) return COLOR_LAVA;            // Lava Bucket
    if (itemId == 108) return COLOR_JACK;            // Jack o'Lantern
    if (itemId == 109) return COLOR_SHROOMLIGHT;     // Shroomlight
    if (itemId == 110) return COLOR_CRYING_OBS;      // Crying Obsidian
    if (itemId == 111 || itemId == 112) return COLOR_CANDLE; // Candles
    if (itemId == 113) return COLOR_BLAZE;           // Blaze Rod
    if (itemId == 114) return COLOR_LAVA;            // Magma Cream
    if (itemId == 115) return COLOR_FIRE;            // Fire Charge
    
    if (itemId == 200) return COLOR_SEA_LANTERN;     // Sea Lantern
    if (itemId == 202) return COLOR_CONDUIT;         // Conduit
    if (itemId == 203) return COLOR_BEACON;          // Beacon
    if (itemId == 206) return COLOR_HEART_SEA;       // Heart of the Sea
    if (itemId == 207) return COLOR_SEA_LANTERN;     // Prismarine
    if (itemId == 208) return COLOR_GLOW_INK;        // Glow Ink Sac
    if (itemId == 209) return COLOR_NETHER_STAR;     // Nether Star
    
    if (itemId == 300) return COLOR_GLOW_LICHEN;     // Glow Lichen
    if (itemId == 301) return COLOR_GLOW_BERRY;      // Glow Berries
    if (itemId == 302) return COLOR_OCHRE;           // Ochre Froglight
    if (itemId == 305) return COLOR_VERDANT;         // Verdant Froglight
    if (itemId == 306) return COLOR_XP_BOTTLE;       // Experience Bottle
    
    if (itemId == 400) return COLOR_END_ROD;         // End Rod
    if (itemId == 401) return COLOR_ENDER;           // Ender Chest
    if (itemId == 404) return COLOR_AMETHYST;        // Amethyst
    if (itemId == 405) return COLOR_DRAGON;          // Dragon's Breath
    if (itemId == 406) return COLOR_ENDER;           // Ender Pearl/Eye
    if (itemId == 407) return COLOR_PEARLESCENT;     // Pearlescent Froglight
    if (itemId == 408) return COLOR_AMETHYST;        // Enchanted Golden Apple
    if (itemId == 409) return COLOR_GLOW_BERRY;      // Totem of Undying (golden)
    if (itemId == 410) return COLOR_ENDER;           // Chorus
    if (itemId == 411) return COLOR_RESPAWN;         // Respawn Anchor
    
    if (itemId == 500) return COLOR_REDSTONE;        // Redstone Torch
    if (itemId == 501) return COLOR_RS_LAMP;         // Redstone Lamp
    if (itemId == 503) return COLOR_REDSTONE;        // Redstone
    if (itemId == 504) return COLOR_MAGMA;           // Magma Block
    
    if (itemId == 600) return COLOR_GLOWSTONE;       // Glowstone
    if (itemId == 601) return COLOR_SEA_LANTERN;     // Sea Pickle
    if (itemId == 603) return COLOR_WHITE;           // Light Block
    
    if (itemId >= 700 && itemId <= 701) return COLOR_COPPER;
    
    return COLOR_DEFAULT;
}

vec3 getLightColorFromBlockId(int blockId) {
    return getLightColorFromItemId(blockId);
}

float calcDynamicLightLevel(float dist, int heldLightLevel) {
    if (heldLightLevel <= 0) return 0.0;
    float maxRadius = float(heldLightLevel);
    if (dist >= maxRadius) return 0.0;
    float lightAtDist = float(heldLightLevel) - dist;
    return clamp(lightAtDist / 15.0, 0.0, 1.0);
}

vec2 adjustLightmapWithDynamicLight(vec2 lmcoord, float dist, int heldLight, int heldLight2) {
    int maxHeld = max(heldLight, heldLight2);
    if (maxHeld <= 0) return lmcoord;
    float dynLight = calcDynamicLightLevel(dist, maxHeld) * DYNAMIC_LIGHT_INTENSITY;
    float newBlockLight = max(lmcoord.x, dynLight);
    return vec2(newBlockLight, lmcoord.y);
}

vec3 getHeldLightColor(int itemId1, int itemId2, int lightLevel1, int lightLevel2) {
    vec3 color1 = (lightLevel1 > 0 && itemId1 > 0) ? getLightColorFromItemId(itemId1) : COLOR_DEFAULT;
    vec3 color2 = (lightLevel2 > 0 && itemId2 > 0) ? getLightColorFromItemId(itemId2) : COLOR_DEFAULT;  
    if (lightLevel1 > 0 && lightLevel2 > 0) {
        float total = float(lightLevel1 + lightLevel2);
        float weight1 = float(lightLevel1) / total;
        return mix(color2, color1, weight1);
    }
    if (lightLevel1 > 0) return color1;
    if (lightLevel2 > 0) return color2;
    return COLOR_DEFAULT;
}

vec3 applyDynamicLightTint(vec3 color, float originalBlockLight, float newBlockLight, vec3 lightColor) {
    float boost = max(0.0, newBlockLight - originalBlockLight);
    if (boost <= 0.001) return color;
    float tintStrength = boost * DYNAMIC_LIGHT_COLOR_INTENSITY;
    return mix(color, color * lightColor, tintStrength);
}

vec3 applyDynamicLightTint(vec3 color, float originalBlockLight, float newBlockLight) {
    return applyDynamicLightTint(color, originalBlockLight, newBlockLight, COLOR_DEFAULT);
}

vec3 getBlockEmissiveColor(float blockId, float lightLevel) {
    if (blockId < 0.0 || lightLevel < 0.01) return vec3(0.0);
    int id = int(blockId + 0.5);
    return getLightColorFromBlockId(id);
}

vec3 calcBlockEmission(float blockId, float vanillaBlockLight) {
    if (blockId < 0.0 || vanillaBlockLight < 0.01) return vec3(0.0);
    int id = int(blockId + 0.5);
    vec3 emitColor = getLightColorFromBlockId(id);
    float emitStrength = vanillaBlockLight * DYNAMIC_LIGHT_COLOR_INTENSITY * 0.5;
    return emitColor * emitStrength;
}

#endif //DYNAMIC_LIGHT_GLSL
