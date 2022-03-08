open Project
open Command

let print_list f l =
  List.fold_left (fun _ y -> print_endline (f y)) () l

let make () =
  print_string "> Content image: ";
  let content = read_line () in
  print_string "> Style image: ";
  let style = read_line () in
  print_string "> Flags: ";
  let flags = read_line () in
  let _ = parse_command content style flags in
  ()
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
    "\n\nWelcome to the 3110 neuron engine.\n";
  print_endline
    "Enter make to start process your image.\n\
     Enter help for a list of flags, or help <\"flg\"> for information \
     about a specific flag. ";
  print_string "> ";
  start ()

(* Execute the program. *)
let () = main ()