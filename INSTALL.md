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

To run the engine,
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
The default flags for filtering/resizing are:
`-k 5`
`-sigma 1.0`
All of the flags are optional. To specify a flag value, use `-flag value`. The flags not specified will use the default values. 
What we generated in MS1 is an "artwork". What we generated in MS2 is a "picture". The differences are explained in our progress report. 
The output artwork is in `/data/output`
