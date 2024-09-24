shader_type canvas_item;

uniform vec3 outline_color : source_color;
uniform float outline_width : hint_range(0.0, 1, 0.01) = 1.0;

// 非循环计算的方式实现描边

// 使用四向材质分离的效果

void fragment() {
	// UV 表示纹理贴图坐标
	// TEXTURE 表示纹理材质
	// TEXTURE_PIXEL_SIZE 表示每个像素的大小
	
	vec2 uv = UV;        // 原本的 UV
	vec4 color = COLOR;  // 原本的 COlOR
	
	// 获取 纹理往四周挪动的坐标
	vec2 uv_up = uv + vec2(0, -TEXTURE_PIXEL_SIZE.y) * outline_width; 
	vec2 uv_down = uv + vec2(0, TEXTURE_PIXEL_SIZE.y) * outline_width; 
	vec2 uv_left = uv + vec2(-TEXTURE_PIXEL_SIZE.x,0) * outline_width; 
	vec2 uv_right = uv + vec2(TEXTURE_PIXEL_SIZE.x, 0) * outline_width; 
	
	// 根据 四周挪动的坐标 获取 新的四个方向颜色
	// texture 函数通过纹理坐标上色
	vec4 color_up = texture(TEXTURE, uv_up);
	vec4 color_down = texture(TEXTURE, uv_down);
	vec4 color_left = texture(TEXTURE, uv_left);
	vec4 color_right = texture(TEXTURE, uv_right);
	
	// 混合四个方向的颜色
	vec4 outline = color_up + color_down + color_left + color_right;
	outline.rgb = outline_color;
	outline.a = min(outline.a, 1);  // 开了 HDR，防止 alpha 炸导致的颜色错误
	
	outline = mix(outline, color, color.a);
	
	COLOR = outline;
}

