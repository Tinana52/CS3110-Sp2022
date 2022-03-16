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
`make build`
`make launch`
Content image can be either of:
`cornell1` `cornell2` `cornell3`
Style image should be `starry`
Pre-trained model should be `vgg16`
No flags required for current version
The output artwork is shown as `art.png`