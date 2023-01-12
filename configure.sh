git submodule update --init --recursive
cd Videomator_core
mkdir build
cd build
conan install ..
cmake ..
cmake --build .
cd ..
cd ..
pod install