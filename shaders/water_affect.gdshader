shader_type canvas_item;

// 实现水中效果

// sampler2D ： 用于采样 2D 纹理，也就是可以导入图片材质等
// repeat_enable ： 纹理能否超过了 UV 的 [0, 1] 范围重复
// hint_screen_texture ： 在着色器中访问当前屏幕的内容，可实现屏幕空间效果（如模糊、后处理效果等）

uniform vec3 color : source_color;      // 水面颜色

uniform sampler2D fast_noise : repeat_enable;   // 噪声，在导出的类别中选择 NoiseTexture2D，然后再在 Noise 中选择 FastNoiseLite，噪声要设置无缝纹理，然后设置噪声种类
uniform sampler2D screen : hint_screen_texture; // 屏幕材质

uniform vec2 speed = vec2(0.03, 0.07);  // 水波速度

uniform float wave_strength = 2;        // 水波强度

void fragment() {
	vec2 uv = UV + speed * TIME;                            // 实现噪声在每一帧渲染时动态移动
	
	vec2 noise = texture(fast_noise, uv).rg;                // 获取噪声在每一帧的材质，且只获取前两个 rgb 值 rg，设置 rg 值作为偏移量，从而然覆盖的图片根据噪声的颜色进行偏移
	vec3 noise_color = texture(fast_noise, uv).rgb;         // 获取噪声的颜色
	
	vec4 tmp_color = vec4(color, 1) + vec4(noise_color, 1); // 让噪声附上外部设置的颜色
	
	// 将屏幕纹理与噪声纹理结合起来
	// 乘法适合颜色混合
	// 加法适合颜色相加
	tmp_color *= texture(screen, SCREEN_UV + noise * (wave_strength / 100.0));
	
	tmp_color.a = 1.0;  // 防止 HDR 炸 alpha
	
	COLOR = tmp_color;
}

