open Torch
open Torch_vision

let load_pretrained_vgg weight_path layers_opt1 layers_content_opt2 cpu
    =
  let model_paras = Var_store.create ~name:"vgg" ~device:cpu () in
  let layers =
    List.sort_uniq compare (layers_opt1 @ layers_content_opt2)
  in
  let max_layer = 1 + List.(rev layers |> hd) in
  let pretrained_model =
    Vgg.vgg16_layers model_paras ~max_layer ~batch_norm:false
    |> Base.Staged.unstage
  in
  let _ =
    Serialize.load_multi_
      ~named_tensors:(Var_store.all_vars model_paras)
      ~filename:weight_path
  in
  let _ = Var_store.freeze model_paras in
  pretrained_model

let load_style_img style_img cpu =
  Imagenet.load_image_no_resize_and_crop style_img
  |> Tensor.to_device ~device:cpu

let load_content_img content_img cpu =
  Imagenet.load_image_no_resize_and_crop content_img
  |> Tensor.to_device ~device:cpu
