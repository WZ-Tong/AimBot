import torch
import sys
import onnx
import onnxruntime
# 将yolov5项目路径添加到系统路径中
sys.path.append('../yolov5-master')  # 替换为你本地yolov5仓库的路径

# 加载yolov5模块
from models.common import DetectMultiBackend
from utils.torch_utils import select_device

# 加载模型
model = DetectMultiBackend('yolov5s.pt', device=select_device('cpu'))  # or 'cuda'

# 设置模型为推理模式
model.model.eval()

# 创建一个 dummy 输入 (batch_size=1, channels=3, height=640, width=640)
dummy_input = torch.randn(1, 3, 640, 640)

# 导出模型为ONNX
torch.onnx.export(model.model, dummy_input, "yolov5s.onnx", opset_version=12,
                  input_names=['input'], output_names=['output'],
                  dynamic_axes={'input': {0: 'batch_size'}, 'output': {0: 'batch_size'}})

print("Model has been successfully exported to yolov5s.onnx")
