#include <onnxruntime_cxx_api.h>
#include <opencv2/opencv.hpp>
#include <algorithm>
#include <iostream>
#include <vector>
#include <fstream>
#include <memory>
#include <cmath>

// YOLOv5 输入图像尺寸
constexpr int input_width = 640;
constexpr int input_height = 640;

// 
void preprocess(const cv::Mat& image, std::vector<float>& input_tensor_values) {
    // 调整大小并归一化图像
    cv::Mat resized_image;
    cv::resize(image, resized_image, cv::Size(input_width, input_height));
    resized_image.convertTo(resized_image, CV_32F, 1.0 / 255.0);

    // 将图像的 BGR 频道转换为 RGB
    cv::cvtColor(resized_image, resized_image, cv::COLOR_BGR2RGB);

    // 按照 (CHW) 格式将图像数据填充到输入 tensor 中
    for (int c = 0; c < 3; ++c) {
        for (int y = 0; y < input_height; ++y) {
            for (int x = 0; x < input_width; ++x) {
                input_tensor_values[c * input_height * input_width + y * input_width + x] = resized_image.at<cv::Vec3f>(y, x)[c];
            }
        }
    }
}

// 读取类别名称文件
std::vector<std::string> load_class_names(const std::string& file_name) {
    std::vector<std::string> class_names;
    std::ifstream infile(file_name);
    if (!infile.is_open()) {
        std::cerr << "Failed to open class names file!" << std::endl;
        return class_names;
    }
    std::string line;
    while (std::getline(infile, line)) {
        class_names.push_back(line);
    }
    infile.close();

// 打印加载的类别数目，方便调试
    std::cout << "Loaded " << class_names.size() << " class names from file." << std::endl;
    return class_names;
}


struct Detection {
    float x, y, w, h, conf;
    int class_id;
};

// 计算两个矩形框的 IOU
float IoU(const Detection& boxA, const Detection& boxB) {
    float xA = std::max(boxA.x - boxA.w / 2, boxB.x - boxB.w / 2);
    float yA = std::max(boxA.y - boxA.h / 2, boxB.y - boxB.h / 2);
    float xB = std::min(boxA.x + boxA.w / 2, boxB.x + boxB.w / 2);
    float yB = std::min(boxA.y + boxA.h / 2, boxB.y + boxB.h / 2);

    float interArea = std::max(0.0f, xB - xA) * std::max(0.0f, yB - yA);
    float boxAArea = boxA.w * boxA.h;
    float boxBArea = boxB.w * boxB.h;

    float iou = interArea / (boxAArea + boxBArea - interArea);
    return iou;
}

// 非极大值抑制实现
std::vector<int> NMS(const std::vector<Detection>& detections, float iou_threshold) {
    std::vector<int> indices;

    // 按置信度从高到低排序
    std::vector<int> sorted_indices(detections.size());
    std::iota(sorted_indices.begin(), sorted_indices.end(), 0);
    std::sort(sorted_indices.begin(), sorted_indices.end(), [&detections](int i1, int i2) {
        return detections[i1].conf > detections[i2].conf;
    });

    while (!sorted_indices.empty()) {
        int best_idx = sorted_indices.front();
        indices.push_back(best_idx);
        sorted_indices.erase(sorted_indices.begin());

        std::vector<int> remaining;
        for (int idx : sorted_indices) {
            if (IoU(detections[best_idx], detections[idx]) < iou_threshold) {
                remaining.push_back(idx);
            }
        }
        sorted_indices = remaining;
    }

    return indices;
}

int main() {
    	// 初始化 ONNX Runtime 环境
    Ort::Env env(ORT_LOGGING_LEVEL_WARNING, "YOLOv5");
    Ort::SessionOptions session_options;
    session_options.SetIntraOpNumThreads(1);
    
    	// 创建会话，加载模型
    const char* model_path = "yolov5s.onnx";
    Ort::Session session(env, model_path, session_options);

	
	// 获取模型输入输出信息
    Ort::AllocatorWithDefaultOptions allocator;

	// 加载完毕
    std::cout << "ONNX model loaded successfully!" << std::endl;
    
    	// 使用 GetInputNameAllocated 和 GetOutputNameAllocated
    Ort::AllocatedStringPtr input_name = session.GetInputNameAllocated(0, allocator);
    Ort::AllocatedStringPtr output_name = session.GetOutputNameAllocated(0, allocator);

    	// 打印输入输出名称（可选）
    std::cout << "Input Name: " << input_name.get() << std::endl;
    std::cout << "Output Name: " << output_name.get() << std::endl;

    	// 读取图像并进行预处理
    cv::Mat image = cv::imread("input.jpg");
    if (image.empty()) {
        std::cerr << "Failed to read image!" << std::endl;
        return -1;
    }
    std::vector<float> input_tensor_values(input_width * input_height * 3);
    std::cout << "图像加载成功啦，赢！" << std::endl;
preprocess(image, input_tensor_values);


	// 加载类别名称
    std::vector<std::string> class_names = load_class_names("coco.names");
    if (class_names.empty()) {
        std::cerr << "No class names loaded, check coco.names file." << std::endl;
        return -1;
    }

    
    	// 创建输入 tensor
    	std::array<int64_t, 4> input_shape = {1, 3, input_height, input_width};
	

	//這是什麼，腦子？
	//啃一口(º﹃º )
	//嚼嚼(๑´ㅂ`๑)嚼嚼
	//嚼嚼(๑´ㅂ`๑)嚼嚼
	//嚼嚼(๑´ㅂ`

	// 设定内存信息
	Ort::MemoryInfo memory_info = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);

	// 创建输入张量,注意哦, 在 ONNX Runtime 16.0 版本中，CreateTensor 函数的签名可能与高版本不一致
	Ort::Value input_tensor = Ort::Value::CreateTensor(
	    memory_info,                                  // 内存信息
	    input_tensor_values.data(),                   // 数据指针
	    input_tensor_values.size(),                   // 数据元素总数
	    input_shape.data(),                           // 张量形状
	    input_shape.size()                            // 张量维度长度
	);

	// 进行推理
    	std::vector<const char*> input_names{input_name.get()};
    	std::vector<const char*> output_names{output_name.get()};
    	auto output_tensors = session.Run(Ort::RunOptions{nullptr}, input_names.data(), &input_tensor, 1, output_names.data(), 1);

	// 获取输出并处理结果
    float* output_data = output_tensors[0].GetTensorMutableData<float>();
    size_t output_size = output_tensors[0].GetTensorTypeAndShapeInfo().GetElementCount();

	// 创建一个列表来存储检测结果
    std::vector<Detection> detections;

    	// 解析模型输出（YOLOv5 输出格式：N x (boxes + conf + class)）
    std::cout << "Output size: " << output_size << std::endl;
    for (size_t i = 0; i < output_size; i += 85) {
        float conf = output_data[i + 4];  // 置信度
        if (conf > 0.5) {  // 设置置信度阈值
            Detection det;
            det.x = output_data[i];        // 中心 x 坐标
            det.y = output_data[i + 1];    // 中心 y 坐标
            det.w = output_data[i + 2];    // 宽度
            det.h = output_data[i + 3];    // 高度
            det.conf = conf;               // 置信度
            det.class_id = std::max_element(output_data + i + 5, output_data + i + 85) - (output_data + i + 5);  // 类别ID
            detections.push_back(det);  // 将结果加入列表
        }
    }

    	// 使用 NMS 去掉重复框
    float iou_threshold = 0.5;  // IOU 阈值
    std::vector<int> nms_indices = NMS(detections, iou_threshold);

    	// 在图像上绘制检测框
    for (int idx : nms_indices) {
        const Detection& det = detections[idx];
        std::string class_name = det.class_id < class_names.size() ? class_names[det.class_id] : "Unknown";
	std::cout << class_names[det.class_id] << std::endl;
        std::cout << "id=" << det.class_id << ", confidence=" << det.conf
                  << ", box=[" << det.x << ", " << det.y << ", " << det.w << ", " << det.h << "]" << std::endl;

        // 转换坐标为左上角和右下角
        int left = static_cast<int>((det.x - det.w / 2));
        int top = static_cast<int>((det.y - det.h / 2));
        int right = static_cast<int>((det.x + det.w / 2));
        int bottom = static_cast<int>((det.y + det.h / 2));
	std::cout << left << "," << top  << std::endl;
        // 绘制矩形框
        cv::rectangle(image, cv::Point(left, top), cv::Point(right, bottom), cv::Scalar(0, 255, 0), 8);
	std::cout << "Detected object: class=" << class_name << std::endl;

	// 显示类名和置信度
        std::string label = class_name + ": " + std::to_string(det.conf);
        cv::putText(image, label, cv::Point(left, top - 5), cv::FONT_HERSHEY_SIMPLEX, 0.5, cv::Scalar(255, 0, 0), 2);	
	
    }

    // 显示带有检测框的图像
    cv::imshow("YOLOv5 Detection", image);
    cv::waitKey(0);  // 等待按键关闭窗口

    return 0;
}

