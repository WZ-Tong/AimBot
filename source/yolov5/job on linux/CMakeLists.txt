
project(YOLOv5_ONNX)

# 设置C++标准
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)


# 头文件路径
include_directories(~/work/onnxruntime-linux-x64-1.16.0/include)

# 库路径
link_directories(~/work/onnxruntime-linux-x64-1.16.0/lib)

# 查找 OpenCV 包
find_package(OpenCV REQUIRED)

# 添加 OpenCV 头文件路径
include_directories(${OpenCV_INCLUDE_DIRS})


add_executable(yolov5 main.cpp)

# 链接 ONNX Runtime 库
target_link_libraries(yolov5 onnxruntime ${OpenCV_LIBS})

# 通过 CMake 强制静态编译
# set(CMAKE_EXE_LINKER_FLAGS "-static")


# 输出调试信息（可选）
message(STATUS "OpenCV include directories: ${OpenCV_INCLUDE_DIRS}")
message(STATUS "OpenCV libraries: ${OpenCV_LIBS}")
message(STATUS "ONNX Runtime include: ${ONNXRUNTIME_DIR}/include")
message(STATUS "ONNX Runtime lib: ${ONNXRUNTIME_DIR}/lib")
