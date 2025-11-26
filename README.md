Fast static build for llama.cpp. AMD/Intel Vulkan EP. 

Get clone the [llama.cpp](https://github.com/ggml-org/llama.cpp) repo  
Copy files to their respective folders. 

Build:
```sh
chmod +x run.sh static-build.sh && ./static-build.sh
```
Enter container:
```sh
./run.sh
```
- Copy contents of build folder to host to get bins:
  ```sh
  cp -r build /code/
  ```
