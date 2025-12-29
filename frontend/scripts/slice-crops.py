from PIL import Image
import os

# 配置
INPUT_PATH = r"C:\Users\HUAWEI\Downloads\crops-v2.1\crops-v2\crops.png"
OUTPUT_DIR = r"C:\Users\HUAWEI\Desktop\game\frontend\public\crops"
TILE_SIZE = 32  # 瓷砖大小

def slice_spritesheet():
    # 创建输出目录
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # 打开图片
    img = Image.open(INPUT_PATH)
    width, height = img.size
    print(f"图片大小: {width}x{height}")
    
    cols = width // TILE_SIZE
    rows = height // TILE_SIZE
    print(f"将切割成 {cols} 列 x {rows} 行 = {cols * rows} 个瓷砖")
    
    count = 0
    for row in range(rows):
        for col in range(cols):
            x = col * TILE_SIZE
            y = row * TILE_SIZE
            
            # 切割瓷砖
            tile = img.crop((x, y, x + TILE_SIZE, y + TILE_SIZE))
            
            # 检查是否为空（全透明）
            if tile.getextrema()[3][1] > 0:  # 有非透明像素
                output_path = os.path.join(OUTPUT_DIR, f"crop_{count:04d}.png")
                tile.save(output_path)
                count += 1
    
    print(f"完成！共切割 {count} 个非空瓷砖到 {OUTPUT_DIR}")

if __name__ == "__main__":
    slice_spritesheet()
