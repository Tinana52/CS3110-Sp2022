open Torch
open Torch_vision

let style_weight = 1e6
let lr = 1e-1
let total_steps = 80

(* desired depth layers to compute style losses : *)
let layers_style_loss = [ 0; 2; 5; 7; 10 ]

(* desired depth layers to compute content losses : *)
let layers_content_loss = [ 7 ]

let gram_matrix m =
  let a, b, c, d = Tensor.shape4_exn m in
  let m = Tensor.view m ~size:[ a * b; c * d ] in
  let g = Tensor.mm m (Tensor.tr m) in
  Tensor.( / ) g (Float.of_int (a * b * c * d) |> Tensor.f)

let load_pretrained_vgg weight_path cpu =
  let model_paras = Var_store.create ~name:"vgg" ~device:cpu () in
  let layers =
    List.sort_uniq compare (layers_style_loss @ layers_content_loss)
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

let get_inputs_tensors cpu argv =
  let style_img_path, content_img_path, weight_path =
    match argv with
    | [| _; style_img; content_img; filename |] ->
        (style_img, content_img, filename)
    | _ ->
        raise
          (Failure
             "Must input: style_img.png content_img.png \
              pretrained_weight.ot")
  in
  let model = load_pretrained_vgg weight_path cpu in
  let style_img = load_style_img style_img_path cpu in
  let content_img = load_content_img content_img_path cpu in
  (model, style_img, content_img)

let get_style_loss input_layers style_layers layers_for_loss =
  let style_loss m1 m2 =
    Tensor.mse_loss (gram_matrix m1) (gram_matrix m2)
  in
  let loss_new_layers lst =
    style_loss
      (Base.Map.find_exn input_layers lst)
      (Base.Map.find_exn style_layers lst)
  in
  List.map loss_new_layers layers_for_loss
  |> List.fold_left Tensor.( + ) (Tensor.of_float0 0.0)

let get_content_loss input_layers content_layers layers_for_loss =
  let loss_new_layers lst =
    Tensor.mse_loss
      (Base.Map.find_exn input_layers lst)
      (Base.Map.find_exn content_layers lst)
  in
  List.map loss_new_layers layers_for_loss
  |> List.fold_left Tensor.( + ) (Tensor.of_float0 0.0)

let get_combined_loss style_loss style_weight content_loss =
  Tensor.((style_loss * f style_weight) + content_loss)

let training_nst
    model
    input_var
    optimizer
    style_layers
    content_layers
    total_steps =
  for iteration = 1 to total_steps do
    Optimizer.zero_grad optimizer;
    let input_layers = model input_var in
    let style_loss =
      get_style_loss input_layers style_layers layers_style_loss
    in
    let content_loss =
      get_content_loss input_layers content_layers layers_content_loss
    in
    let loss = get_combined_loss style_loss style_weight content_loss in
    Tensor.backward loss;
    Optimizer.step optimizer;
    Tensor.no_grad (fun () ->
        ignore (Imagenet.clamp_ input_var : Tensor.t));
    let _ =
      Stdio.printf
        "Iteration: %d,  Combined Loss: %.4f, Style Loss: %.4f, \
         Content Loss: %.4f\n\
         %!"
        iteration
        (Tensor.float_value loss)
        (Tensor.float_value style_loss)
        (Tensor.float_value content_loss)
    in
    Caml.Gc.full_major ()
  done

let () =
  let module Sys = Caml.Sys in
  let cpu = Device.cuda_if_available () in
  let model, style_img, content_img = get_inputs_tensors cpu Sys.argv in
  let model_paras = Var_store.create ~name:"optim" ~device:cpu () in
  let copied_model_paras =
    Var_store.new_var_copy model_paras ~src:content_img ~name:"in"
  in
  let style_layers, content_layers =
    let detach = Base.Map.map ~f:Tensor.detach in
    Tensor.no_grad (fun () ->
        (model style_img |> detach, model content_img |> detach))
  in
  let optimizer = Optimizer.adam model_paras ~learning_rate:lr in
  let _ = Stdio.printf "Training begin for the new artwork \n%!" in
  let _ =
    training_nst model copied_model_paras optimizer style_layers
      content_layers total_steps
  in
  Imagenet.write_image copied_model_paras ~filename:"art.png"
