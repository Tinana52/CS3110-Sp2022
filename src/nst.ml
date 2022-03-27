open Torch
open Torch_vision
open Loader
open Loss
open Command

(* let style_weight = 1e6 let lr = 1e-1 let total_steps = 80

   (* desired depth layers to compute style losses : *) let
   layers_style_loss = [ 0; 2; 5; 6; 7 ]

   (* desired depth layers to compute content losses : *) let
   layers_content_loss = [ 7 ] *)
let flags = ref default

let get_inputs_tensors cpu style_img_path content_img_path weight_path =
  let model =
    load_pretrained_vgg weight_path !flags.layers_style_loss
      !flags.layers_content_loss cpu
  in
  let style_img = load_style_img style_img_path cpu in
  let content_img = load_content_img content_img_path cpu in
  (model, style_img, content_img)

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
      get_style_loss input_layers style_layers !flags.layers_style_loss
    in
    let content_loss =
      get_content_loss input_layers content_layers
        !flags.layers_content_loss
    in
    let loss =
      get_combined_loss style_loss !flags.style_weight content_loss
    in
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

let main style content model input_flags =
  let () = flags := input_flags in
  let module Sys = Caml.Sys in
  let cpu = Device.cuda_if_available () in
  let model, style_img, content_img =
    get_inputs_tensors cpu style content model
  in
  let model_paras = Var_store.create ~name:"optim" ~device:cpu () in
  let copied_model_paras =
    Var_store.new_var_copy model_paras ~src:content_img ~name:"in"
  in
  let style_layers, content_layers =
    let detach = Base.Map.map ~f:Tensor.detach in
    Tensor.no_grad (fun () ->
        (model style_img |> detach, model content_img |> detach))
  in
  let optimizer =
    Optimizer.adam model_paras ~learning_rate:!flags.learning_rate
  in
  let _ = Stdio.printf "Training begin for the new artwork \n%!" in
  let _ =
    training_nst model copied_model_paras optimizer style_layers
      content_layers !flags.total_steps
  in
  Imagenet.write_image copied_model_paras ~filename:"art.png"