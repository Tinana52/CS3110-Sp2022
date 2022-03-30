Step 0: update system
`sudo apt update`
`sudo apt upgrade`


Step 1: install required packages
`sudo apt install pkg-config libffi-dev zlib1g-dev`

Step 2: install ocaml pytorch
`opam install torch ANSITerminal`

Step 3: download the pretrained VGG-16 weights from 
https://github.com/LaurentMazare/ocaml-torch/releases/download/v0.1-unstable/vgg16.ot
and save the file in folder `/resources`

Step 4: install openCV locally:
`cd ~`
`sudo cmake`
`wget -O opencv.zip https://github.com/opencv/opencv/archive/4.x.zip`
`unzip opencv.zip`
`mkdir -p build && cd build`
`cmake  ../opencv-4.x`
`cmake --build .`

Step 5: install OpenCV-Ocaml:
`sudo apt install liblapacke-dev libopenblas-dev`
`export PKG_CONFIG_PATH="/usr/local/opt/openblas/lib/pkgconfig"`
`eval $(opam env)`
`opam pin add opencv https://github.com/Calsign/ocaml-opencv.git`

To run the engine,
`make build`
`make launch`
Content image can be either of:
`cornell1` `cornell2` `cornell3`
Style image should be `starry`
Pre-trained model should be `vgg16`
## For VGG16, the default flags that work:
`-layers_style_loss [0,2,5,7,10]`
`-layers_content_loss [7]`
`-style_weight 1e6`
`-learning_rate 1e-1`
`-total_steps 80`
## We will update this list as soon as we add more pretrained models
The output artwork is shown as `art.png`
