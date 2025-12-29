from PIL import Image
import os

INPUT_DIR = r"C:\Users\HUAWEI\Downloads\444\crops"
OUTPUT_DIR = r"C:\Users\HUAWEI\Desktop\game\frontend\public\crops"
FRAME_WIDTH = 16
FRAME_HEIGHT = 32

def slice_crop(filename):
    name = os.path.splitext(filename)[0]
    if name == "crops - all":
        return
    
    img = Image.open(os.path.join(INPUT_DIR, filename))
    width, height = img.size
    
    frames = width // FRAME_WIDTH
    print(f"{name}: {width}x{height}, {frames} 帧")
    
    # 创建作物子目录
    crop_dir = os.path.join(OUTPUT_DIR, name)
    os.makedirs(crop_dir, exist_ok=True)
    
    for i in range(frames):
        x = i * FRAME_WIDTH
        frame = img.crop((x, 0, x + FRAME_WIDTH, height))
        frame.save(os.path.join(crop_dir, f"{i}.png"))

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    for filename in os.listdir(INPUT_DIR):
        if filename.endswith(".png"):
            slice_crop(filename)
    
    print("完成!")

if __name__ == "__main__":
    main()
