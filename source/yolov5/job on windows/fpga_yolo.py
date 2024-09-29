"""
本文件用于在嵌入式系统上运行，测试onnx是否可用
"""
import onnx
import onnxruntime as ort
import numpy as np

# 1. 加载ONNX模型
onnx_model_path = "yolov5s.onnx"  # 替换为你的ONNX模型路径
onnx_model = onnx.load(onnx_model_path)

# 2. 检查模型的有效性
onnx.checker.check_model(onnx_model)
print("ONNX模型有效!")

# 3. 创建一个ONNX Runtime推理会话
ort_session = ort.InferenceSession(onnx_model_path)

# 4. 准备输入数据
# 假设模型输入需要一个大小为 (1, 3, 640, 640) 的张量 (batch_size=1, 3通道，640x640图像)
dummy_input = np.random.randn(1, 3, 640, 640).astype(np.float32)

# 5. 执行推理
outputs = ort_session.run(None, {"input": dummy_input})

# 6. 输出结果
print("模型推理输出:", outputs)
