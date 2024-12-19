layout(location = 0) uniform float iTime;
layout(location = 1) uniform vec2 iResolution;

layout(location = 0) out vec4 fragColor;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
        u.y
    );
}

float fbm(vec2 p) {
    float total = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for (int i = 0; i < 5; i++) {
        total += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return total;
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    uv.x *= iResolution.x / iResolution.y;

    float time = iTime * 0.2;

    // Wave calculations
    float waveHeight = fbm(uv * 5.0 + vec2(time, time * 0.5));
    waveHeight += 0.2 * sin(uv.x * 20.0 + time * 2.0);
    waveHeight += 0.1 * sin(uv.y * 30.0 - time * 3.0);

    vec3 oceanColor = vec3(0.0, 0.3, 0.5);
    vec3 highlightColor = vec3(0.6, 0.8, 1.0);

    vec3 color = mix(oceanColor, highlightColor, smoothstep(0.3, 0.7, waveHeight));

    fragColor = vec4(color, 1.0);
}
