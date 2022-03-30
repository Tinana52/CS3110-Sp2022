open Torch
open Torch_vision

(* ############## THIS IS COPIED FROM TORCH SOURCE CODE ##############
   We need these to have normalize and unnormalize working for torch*)
let imagenet_mean_and_std = function
  | `red -> (0.485, 0.229)
  | `green -> (0.456, 0.224)
  | `blue -> (0.406, 0.225)

let mean_, std_ =
  [
    imagenet_mean_and_std `red;
    imagenet_mean_and_std `green;
    imagenet_mean_and_std `blue;
  ]
  |> Base.List.unzip

let clamp_ =
  let normalize kind x =
    let mean, std = imagenet_mean_and_std kind in
    (x -. mean) /. std
  in
  let min_max kind = (normalize kind 0., normalize kind 1.) in
  fun tensor ->
    let clamp_ kind index =
      let min, max = min_max kind in
      Tensor.narrow tensor ~dim:1 ~start:index ~length:1
      |> Tensor.clamp ~min:(Scalar.float min) ~max:(Scalar.float max)
      |> fun (_ : Tensor.t) -> ()
    in
    clamp_ `red 0;
    clamp_ `green 1;
    clamp_ `blue 2;
    tensor

let mean_ =
  lazy (Tensor.float_vec mean_ |> Tensor.view ~size:[ 3; 1; 1 ])

let std_ = lazy (Tensor.float_vec std_ |> Tensor.view ~size:[ 3; 1; 1 ])

let normalize tensor =
  let mean_ = Lazy.force mean_ in
  let std_ = Lazy.force std_ in
  let tensor = Tensor.to_type tensor ~type_:(T Float) in
  Tensor.(((tensor / f 255.) - mean_) / std_)

let unnormalize tensor =
  let mean_ = Lazy.force mean_ in
  let std_ = Lazy.force std_ in
  Tensor.(((tensor * std_) + mean_) * f 255.)
  |> Tensor.clamp ~min:(Scalar.float 0.) ~max:(Scalar.float 255.)
  |> Tensor.to_type ~type_:(T Uint8)

(* ############# Above IS COPIED FROM TORCH SOURCE CODE ############ *)

let output_tensor tensor = Tensor.to_type tensor ~type_:(T Float)
let get_shape_str tensor = Tensor.shape_str tensor

let get_img_size tensor =
  let lst = get_shape_str tensor |> String.split_on_char ',' in
  List.nth lst 1 |> String.trim |> int_of_string

let print_shape tensor =
  Stdio.print_endline
    ("The shape of this tensor is: " ^ get_shape_str tensor)

(** load_image_no_resize_and_crop reads the image, store it in a
    <1,channel,width,hight> tensor; [read_img_to_tensor] gets the
    <channel,width,hight> tensor, which is the representation for the
    read image. Note: this doesn't normalize the image!! *)
let read_img_to_tensor (filename : string) : Tensor.t =
  Imagenet.load_image_no_resize_and_crop filename
  |> unnormalize |> Tensor.to_list |> List.hd

(** Basically the same function as in read_img_to_tensor, but allow
    reshaping into [size] where [size] is (width, height). Note: this
    doesn't normalize the image!! *)
let read_img_to_tensor_reshape (filename : string) (size : int * int) :
    Tensor.t =
  let load_image filename size =
    Image.load_image filename ~resize:size
    |> Base.Or_error.ok_exn |> output_tensor
  in
  load_image filename size |> Tensor.to_list |> List.hd
