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