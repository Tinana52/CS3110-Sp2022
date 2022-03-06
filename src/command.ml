open Yojson.Basic.Util

exception Invalid_Flag of string
exception TypeMismatch

type flag_type =
  | Int of int
  | Float of float
  | String of string
  | IntList of int list
  | FloatList of float list
  | StringList of string list

type flag = {
  name : string;
  arg_type : string;
  value : flag_type;
  info : string;
}

type command = {
  content : string;
  style : string;
  flags : flag list;
}

let flags_from_json t =
  let flags = t |> member "flags" |> to_list in
  List.map
    (fun flg ->
      let arg = flg |> member "arg_type" |> to_string in
      {
        name = flg |> member "flag" |> to_string;
        arg_type = arg;
        value =
          (flg |> member "default"
          |>
          if arg = "int" then fun x -> Int (to_int x)
          else if arg = "float" then fun x -> Float (to_float x)
          else if arg = "int list" then fun x ->
            IntList (List.map to_int (to_list x))
          else fun x -> FloatList (List.map to_float (to_list x)));
        info = flg |> member "info" |> to_string;
      })
    flags

let flags = flags_from_json (Yojson.Basic.from_file "help.json")

let list_of_string str t =
  String.sub str 1 (String.length str - 2)
  |> String.split_on_char ','
  |> List.map String.trim
  |> fun x ->
  if t = "int list" then IntList (List.map int_of_string x)
  else if t = "float list" then FloatList (List.map float_of_string x)
  else StringList x

let split_input str =
  str
  |> String.split_on_char '-'
  |> List.filter (( <> ) "")
  |> List.map (fun x ->
         let space = String.index x ' ' in
         let flag = String.sub x 0 space in
         let value =
           String.sub x (space + 1) (String.length x - space - 1)
         in
         (String.trim flag, String.trim value))

let parse_command content style str =
  {
    content = "data/" ^ content ^ ".jpg";
    style = "data/" ^ style ^ ".jpg";
    flags =
      List.map
        (fun (f, v) ->
          let flag =
            try List.find (fun x -> x.name = f) flags
            with Not_found -> raise (Invalid_Flag f)
          in
          try
            {
              flag with
              value =
                (match flag.arg_type with
                | "int" -> Int (int_of_string v)
                | "float" -> Float (float_of_string v)
                | "string" -> String v
                | "int list" -> list_of_string v "int list"
                | "float list" -> list_of_string v "float list"
                | "string list" -> list_of_string v "string list"
                | _ -> raise (Invalid_Flag flag.name));
            }
          with Failure _ -> raise TypeMismatch)
        (split_input str);
  }

let all_flags =
  List.map (fun x -> "-" ^ x.name ^ " : " ^ x.arg_type) flags

let flag_info flag =
  let f =
    try List.find (fun x -> x.name = flag) flags
    with Not_found -> raise (Invalid_Flag flag)
  in
  f.info

let get_content cmd = cmd.content
let get_style cmd = cmd.style
let get_flags cmd = List.map (fun x -> (x.name, x.value)) cmd.flags
