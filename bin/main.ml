open Project
open Command
open Img

let print_list f l =
  List.fold_left (fun _ y -> print_endline (f y)) () l

let find name flags = List.find (fun (x, _) -> x = name) flags
let tmp_file_loc name = "tmp" ^ Filename.dir_sep ^ name ^ ".jpg"

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
  let cmd =
    parse_command content style pre_trained_model flags output
  in
  let flgs = get_all_flags cmd in
  let res = tmp_file_loc "resize" in
  let gaus = tmp_file_loc "gaussian" in
  let grad = tmp_file_loc "gradient" in
  Sys.remove res;
  Sys.remove gaus;
  Sys.remove grad;
  print_endline "Resizing image...";
  demo_resize (get_content cmd) res flgs.size;
  print_endline "Blurring...";
  demo_gaussian (get_content cmd) gaus flgs.k flgs.sigma;
  print_endline "Generating gradient...";
  demo_gradient (get_content cmd) grad flgs.k flgs.sigma;
  Nst.main (get_style cmd) res (get_model cmd) flgs
    (get_output cmd "resize");
  Nst.main (get_style cmd) gaus (get_model cmd) flgs
    (get_output cmd "gaussian");
  Nst.main (get_style cmd) grad (get_model cmd) flgs
    (get_output cmd "gradient");
  Sys.remove res;
  Sys.remove gaus;
  Sys.remove grad;
  print_endline
    ("Outputed to data" ^ Filename.dir_sep ^ "output" ^ Filename.dir_sep);
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
      | Loader.File_not_found s ->
          print_endline ("File not found: " ^ s);
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