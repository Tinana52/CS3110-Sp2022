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

let remove_tmp () =
  let _ = Sys.command "rm -rf tmp" in
  ()

let read_content () =
  print_string "> Content image: ";
  read_line ()

let read_style () =
  print_string "> Style image: ";
  read_line ()

let read_model () =
  print_string "> Pre-trained model: ";
  read_line ()

let read_flags () =
  print_string "> Flags: ";
  read_line ()

let read_output () =
  print_string "> Output file name: ";
  read_line ()

let read_method () =
  print_endline "> Artwork or picture? [artwork/picture] ";
  print_string "> ";
  read_line ()

let exists get cmd =
  if not (Sys.file_exists (get cmd)) then
    raise (File_not_found (get cmd))

let rec make () =
  let content = read_content () in
  let style = read_style () in
  let pre_trained_model = read_model () in
  let flags = read_flags () in
  let output = read_output () in
  let response = read_method () in
  let cmd = parse_make content style pre_trained_model flags output in
  exists get_content cmd;
  exists get_style cmd;
  exists get_model cmd;
  if response = "artwork" then (
    remove_tmp ();
    artwork cmd)
  else if response = "picture" then (
    remove_tmp ();
    picture cmd)
  else failwith "Invalid. ";
  remove_tmp ();
  print_endline
    ("Output location: data" ^ Filename.dir_sep ^ "output"
   ^ Filename.dir_sep);
  print_string "> ";
  start ()
(* TODO: preprocess image + ml stuff. () |> make |> preprocessing |> ml
   to be () in the end. *)

and start () =
  match parse_input (read_line ()) with
  | exception End_of_file ->
      print_string "Critical error. ";
      print_string "> ";
      start ()
  | exception Invalid_Command s ->
      print_endline ("Invalid command: " ^ s);
      print_string "> ";
      start ()
  | Quit -> ()
  | Info ->
      print_list Fun.id all_flags;
      print_string "> ";
      start ()
  | Make -> (
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
  | Help s -> (
      try
        print_endline (flag_info s);
        print_string "> ";
        start ()
      with Invalid_Flag f ->
        print_endline ("Invalid flag: " ^ f);
        print_string "> ";
        start ())
  | Clean ->
      let _ = Sys.command "rm -rf data/output && mkdir data/output" in
      print_endline "Done. ";
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