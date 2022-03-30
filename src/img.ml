open Torch
open Torch_vision
open Img_helper

let test_in = "data/cornell1.jpg"
let test_out = "data/test_out_full_color.jpg"
let test_out_grey = "data/test_out_one_channel.jpg"

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