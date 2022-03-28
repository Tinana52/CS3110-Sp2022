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

type flags = {
  style_weight : float;
  learning_rate : float;
  total_steps : int;
  layers_style_loss : int list;
  layers_content_loss : int list;
}

type command = {
  content : string;
  style : string;
  model : string;
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
          else if arg = "string" then fun x -> String (to_string x)
          else if arg = "int list" then fun x ->
            IntList (List.map to_int (to_list x))
          else if arg = "float list" then fun x ->
            FloatList (List.map to_float (to_list x))
          else fun x -> StringList (List.map to_string (to_list x)));
        info = flg |> member "info" |> to_string;
      })
    flags

let find_flag flags name =
  (List.find (fun x -> x.name = name) flags).value

let flags =
  let flgs =
    flags_from_json (Yojson.Basic.from_file "resources/help.json")
  in
  List.sort (fun x y -> String.compare x.name y.name) flgs

let list_of_string str t =
  String.sub str 1 (String.length str - 2)
  |> String.split_on_char ','
  |> List.map String.trim
  |> fun x ->
  if t = "int list" then IntList (List.map int_of_string x)
  else if t = "float list" then FloatList (List.map float_of_string x)
  else
    StringList
      (List.map (fun y -> String.sub y 1 (String.length y - 2)) x)

let split_input str =
  str
  |> String.split_on_char '-'
  |> List.filter (( <> ) "")
  |> List.map (fun x ->
         let space =
           try String.index x ' '
           with Not_found -> raise (Invalid_Flag x)
         in
         let flag = String.sub x 0 space in
         let value =
           String.sub x (space + 1) (String.length x - space - 1)
         in
         (String.trim flag, String.trim value))
  |> List.sort (fun (x, _) (y, _) -> String.compare x y)

let parse_value v flag =
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
  with Failure _ -> raise TypeMismatch

let parse_command content style model input_flags =
  {
    content = "data" ^ Filename.dir_sep ^ String.trim content ^ ".jpg";
    style = "data" ^ Filename.dir_sep ^ String.trim style ^ ".jpg";
    model = "resources" ^ Filename.dir_sep ^ String.trim model ^ ".ot";
    flags =
      begin
        let rec parse_flags input default =
          match (input, default) with
          | (flg, v) :: t1, flag :: t2 ->
              if flg = flag.name then
                parse_value v flag :: parse_flags t1 t2
              else flag :: parse_flags ((flg, v) :: t1) t2
          | (f, v) :: _, [] -> raise (Invalid_Flag f)
          | [], l -> l
        in
        List.sort
          (fun x y -> String.compare x.name y.name)
          (parse_flags (split_input input_flags) flags)
      end;
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
let get_model cmd = cmd.model

let get_flags flags =
  {
    style_weight =
      (match find_flag flags "style_weight" with
      | Float x -> x
      | _ -> failwith "Internal error. ");
    learning_rate =
      (match find_flag flags "learning_rate" with
      | Float x -> x
      | _ -> failwith "Internal error. ");
    total_steps =
      (match find_flag flags "total_steps" with
      | Int x -> x
      | _ -> failwith "Internal error. ");
    layers_content_loss =
      (match find_flag flags "layers_content_loss" with
      | IntList x -> x
      | _ -> failwith "Internal error. ");
    layers_style_loss =
      (match find_flag flags "layers_style_loss" with
      | IntList x -> x
      | _ -> failwith "Internal error. ");
  }

let get_all_flags cmd = get_flags cmd.flags
let default = get_flags flags
