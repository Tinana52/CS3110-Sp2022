open Project
open Command
open Nst

let print_list f l =
  List.fold_left (fun _ y -> print_endline (f y)) () l

let find name flags = List.find (fun (x, _) -> x = name) flags

let make () =
  print_string "> Content image: ";
  let content = read_line () in
  print_string "> Style image: ";
  let style = read_line () in
  print_string "> Pre-trained model: ";
  let pre_trained_model = read_line () in
  print_string "> Flags: ";
  let flags = read_line () in
  let cmd = parse_command content style pre_trained_model flags in
  (* let flags = get_flags cmd in let style_weight = match find
     "style_weight" flags with | _, Float f -> f | _, _ -> failwith
     "Unknown error" in let learning_rate = match find "learning_rate"
     flags with | _, Float f -> f | _, _ -> failwith "Unknown error" in
     let total_steps = match find "total_steps" flags with | _, Int i ->
     i | _, _ -> failwith "Unknown error" in let layers_style_loss =
     match find "layers_style_loss" flags with | _, IntList i -> i | _,
     _ -> failwith "Unknown error" in let layers_content_loss = match
     find "layers_content_loss" flags with | _, IntList i -> i | _, _ ->
     failwith "Unknown error" in *)
  Nst.main (get_style cmd) (get_content cmd) (get_model cmd)
(* TODO: preprocess image + ml stuff. Have () |> make |> preprocessing
   |> ml to be () in the end. *)

let rec start () =
  match read_line () with
  | exception End_of_file ->
      print_string "Critical error. ";
      ()
  | "quit" -> ()
  | "help" ->
      print_list Fun.id all_flags;
      print_string "> ";
      start ()
  | "make" -> (
      try make () with
      | Invalid_Flag f ->
          print_endline ("Invalid flag: " ^ f);
          print_string "> ";
          start ()
      | TypeMismatch ->
          print_endline "Incorrect arguent type. ";
          print_string "> ";
          start ())
  | cmd when String.sub cmd 0 4 = "help" -> (
      try
        print_endline
          (flag_info (String.sub cmd 5 (String.length cmd - 5)));
        print_string "> ";
        start ()
      with Invalid_Flag f ->
        print_endline ("Invalid flag: " ^ f);
        print_string "> ";
        start ())
  | _ ->
      print_endline "Invalid command. ";
      print_string "> ";
      start ()

let main () =
  ANSITerminal.print_string [ ANSITerminal.red ]
    "\n\nWelcome to the 3110 neural transfer engine.\n";
  print_endline
    "Enter make to start process your image.\n\
     Enter help for a list of flags, or help <\"flg\"> for information \
     about a specific flag. ";
  print_string "> ";
  start ()

(* Execute the program. *)
let () = main ()