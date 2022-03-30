open Torch
open Torch_vision
open Img_helper

let test_in = "data/cornell1.jpg"
let test_out = "data/test_out_full_color.jpg"
let test_out_grey = "data/test_out_one_channel.jpg"

(** load_image_no_resize_and_crop reads the image, store it in a
    <1,channel,width,hight> tensor; [read_img_to_tensor] gets the
    <channel,width,hight> tensor, which is the representation for the
    read image. Note: this doesn't normalize the image!! *)
let read_img_to_tensor (filename : string) : Tensor.t =
  Imagenet.load_image_no_resize_and_crop filename
  |> unnormalize |> Tensor.to_list |> List.hd

(** Basically the same function as in read_img_to_tensor, but allow
    reshaping into [size] where [size] is (width, hight). Note: this
    doesn't normalize the image!! *)
let read_img_to_tensor_reshape (filename : string) (size : int * int) :
    Tensor.t =
  let load_image filename size =
    Image.load_image filename ~resize:size
    |> Base.Or_error.ok_exn |> output_tensor
  in
  load_image filename size |> Tensor.to_list |> List.hd

let demo_get_full_img =
  (* get the tensor, for example Tensor<3,1024,1024> from the image *)
  let img_tensor = read_img_to_tensor_reshape test_in (1024, 1024) in
  (* get the float array array array from the tensor *)
  let img_3d_float = img_tensor |> Tensor.to_float3_exn in
  (* get tensor from the 3d float, tensor_from_3d is <3,256,256> *)
  let tensor_from_3d = img_3d_float |> Tensor.of_float3 in
  (* normalize only works for tensor of 3 channels!!! *)
  let normalized = tensor_from_3d |> normalize in
  (* write to output *)
  Imagenet.write_image ~filename:test_out normalized

let demo_get_one_channel =
  (* get the tensor, for example Tensor<3,256,256> from the image *)
  let img_tensor = read_img_to_tensor_reshape test_in (256, 256) in
  (* get the float array array array from the tensor *)
  let img_3d_float = img_tensor |> Tensor.to_float3_exn in
  let red_channel_2d = img_3d_float.(0) in
  (* [red_channel_2d] gets the first channel of the 3 channel layers;
     img_red_channel_float is of size 1,256, 256*)
  let img_red_channel_float = [| red_channel_2d |] in
  (* get tensor from the 3d float, tensor_from_3d is <1,256,256> *)
  let tensor_from_3d = img_red_channel_float |> Tensor.of_float3 in
  (* normalize only works for tensor of 3 channels!!! *)
  let normalized = tensor_from_3d |> normalize in
  (* write to output, Imagenet.write_image only takes Tensor<3,wid,high>
     or Tensor<1,wid,high>*)
  Imagenet.write_image ~filename:test_out_grey normalized

let main = ()