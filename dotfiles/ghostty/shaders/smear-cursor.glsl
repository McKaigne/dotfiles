// Ghostty Cursor Smear Shader
// Smooth glow and motion trail following the cursor position

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 terminalColor = texture(iChannel0, uv);

    // Get cursor position and size in normalized coordinates
    vec2 cursorPos = iCursor.xy / iResolution.xy;
    vec2 cursorSize = iCursor.zw / iResolution.xy;

    // Center of cursor
    vec2 cursorCenter = cursorPos + cursorSize * 0.5;

    // Aspect ratio correction for smooth circular/oval glow
    float aspect = iResolution.x / iResolution.y;
    vec2 diff = (uv - cursorCenter);
    diff.x *= aspect;

    // Distance metric for smear/glow
    float dist = length(diff);
    float glow = smoothstep(0.035, 0.002, dist) * 0.45;

    // Mix terminal output with smear trail glow
    vec3 glowColor = vec3(0.45, 0.78, 0.95); // Subtle pastel blue/cyan glow
    fragColor = vec4(terminalColor.rgb + (glowColor * glow * (1.0 - terminalColor.a * 0.2)), terminalColor.a);
}