Fast static build for llama.cpp. AMD/Intel Vulkan EP. 

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
