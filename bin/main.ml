open Project
open Command
open Img

exception File_not_found of string

let print_list f l =
  List.fold_left (fun _ y -> print_endline (f y)) () l

let find name flags = List.find (fun (x, _) -> x = name) flags
let tmp_file_loc name = "tmp" ^ Filename.dir_sep ^ name ^ ".jpg"

let artwork cmd =
  Nst.main (get_style cmd) (get_content cmd) (get_model cmd)
    (get_all_flags cmd) (get_output cmd)

let picture cmd =
  let res_cont = tmp_file_loc "resize_style" in
  let flgs = get_all_flags cmd in
  let res_style = tmp_file_loc "resize_content" in
  let gaus_cont = tmp_file_loc "gaussian_content" in
  (* let gaus_style = tmp_file_loc "gaussian_style" in *)
  let grad = tmp_file_loc "gradient" in
  let _ = Sys.command "mkdir tmp" in
  print_endline "Resizing... ";
  demo_resize_default (get_content cmd) res_cont;
  demo_resize_default (get_style cmd) res_style;
  print_endline "Generating gradient... ";
  demo_gradient res_style grad flgs.k flgs.sigma;
  print_endline "Blurring... ";
  demo_gaussian res_cont gaus_cont flgs.k flgs.sigma;
  (* demo_gaussian grad gaus_style flgs.k flgs.sigma; *)
  Nst.main grad gaus_cont (get_model cmd) flgs (get_output cmd)

let rec make () =
  print_string "> Content image: ";
  let content = read_line () in
  print_string "> Style image: ";
  let style = read_line () in
  print_string "> Pre-trained model: ";
  let pre_trained_model = read_line () in
  print_string "> Flags: ";
  let flags = read_line () in
  print_string "> Output file name: ";
  let output = read_line () in
  print_endline "> Artwork or picture? [artwork/picture] ";
  print_string "> ";
  let response = read_line () in
  let cmd =
    parse_command content style pre_trained_model flags output
  in
  if not (Sys.file_exists (get_content cmd)) then
    raise (File_not_found (get_content cmd));
  if not (Sys.file_exists (get_style cmd)) then
    raise (File_not_found (get_style cmd));
  if not (Sys.file_exists (get_model cmd)) then
    raise (File_not_found (get_model cmd));
  (try
     let _ = Sys.is_directory "tmp" in
     let _ = Sys.command "rm -r tmp" in
     ()
   with Sys_error _ -> ());
  if response = "artwork" then artwork cmd
  else if response = "picture" then picture cmd
  else failwith "Invalid. ";
  let _ = Sys.command "rm -r tmp" in
  print_endline
    ("Output location: data" ^ Filename.dir_sep ^ "output"
   ^ Filename.dir_sep);
  print_string "> ";
  start ()
(* TODO: preprocess image + ml stuff. () |> make |> preprocessing |> ml
   to be () in the end. *)

and start () =
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
          start ()
      | File_not_found s ->
          print_endline ("File not found: " ^ s);
          print_string "> ";
          start ()
      | Failure s ->
          print_endline s;
          print_string "> ";
          start ())
  | cmd when String.length cmd > 4 && String.sub cmd 0 4 = "help" -> (
      try
        print_endline
          (flag_info (String.sub cmd 5 (String.length cmd - 5)));
        print_string "> ";
        start ()
      with Invalid_Flag f ->
        print_endline ("Invalid flag: " ^ f);
        print_string "> ";
        start ())
  | "clean" ->
      let _ = Sys.command "rm -r data/output && mkdir data/output" in
      print_string "> ";
      start ()
  | _ ->
      print_endline "Invalid command. ";
      print_string "> ";
      start ()

let main () =
  ANSITerminal.print_string [ ANSITerminal.red ]
    "\n\nWelcome to the 3110 neural transfer engine.\n";
  print_endline
    "Enter make to start process your image.\n\
     Enter help for a list of flags, or help <flag> for information \
     about a specific flag. ";
  print_string "> ";
  start ()

(* Execute the program. *)
let () = main ()