open OUnit2
open Project
open Command

let rec assert_deep_equal lst1 lst2 printer =
  match (lst1, lst2) with
  | [], [] -> ()
  | _ :: _, [] | [], _ :: _ -> failwith "unequal lengths"
  | h1 :: t1, h2 :: t2 ->
      if h1 = h2 then assert_deep_equal t1 t2 printer
      else failwith (printer h1 ^ " not equal to " ^ printer h2)

(* Test cases for Command. *)
let all_flags_test =
  "all flags according to help.json" >:: fun _ ->
  assert_deep_equal
    [
      "-int_lst : int list";
      "-learning_rate : float";
      "-str_lst : string list";
      "-style_weight : int";
    ]
    all_flags Fun.id

let flag_info_test name flag expected_output =
  name >:: fun _ ->
  assert_equal (flag_info flag) expected_output ~printer:Fun.id

let content_test name cmd expected_output =
  name >:: fun _ ->
  assert_equal (get_content cmd) expected_output ~printer:Fun.id

let style_test name cmd expected_output =
  name >:: fun _ ->
  assert_equal (get_style cmd) expected_output ~printer:Fun.id

let flags_test name cmd expected_output =
  name >:: fun _ ->
  assert_deep_equal (get_flags cmd) expected_output (fun (n, v) ->
      n ^ " "
      ^
      match v with
      | Int x -> string_of_int x
      | Float x -> string_of_float x
      | String x -> Fun.id x
      | IntList x ->
          "[" ^ String.concat "; " (List.map string_of_int x) ^ "]"
      | FloatList x ->
          "[" ^ String.concat "; " (List.map string_of_float x) ^ "]"
      | StringList x -> "[" ^ String.concat "; " x ^ "]")

let parse_fail_flag name content style flags inv_flg =
  name >:: fun _ ->
  assert_raises (Invalid_Flag inv_flg) (fun () ->
      parse_command content style flags)

let parse_fail_type name content style flags =
  name >:: fun _ ->
  assert_raises TypeMismatch (fun () ->
      parse_command content style flags)

let cmd1 = parse_command "default" "default" "vgg16" ""

let cmd2 =
  parse_command "default" "default" "vgg16" "-learning_rate 2.0"

let cmd3 =
  parse_command "default" "default" "vgg16"
    "-learning_rate 2.0 -str_lst [\"apple\", \"banana\"] -int_lst \
     [2344,10] -style_weight 10"

let command_tests =
  [
    all_flags_test;
    flag_info_test "info of style_weight" "style_weight" "style weight";
    flag_info_test "info of learning_rate" "learning_rate"
      "learning rate";
    flag_info_test "info of int_lst" "int_lst" "int_list";
    flag_info_test "info of str_lst" "str_lst" "string_list";
    content_test "default content" cmd1 "data/default.jpg";
    style_test "default style" cmd1 "data/default.jpg";
    flags_test "no flag provided" cmd1
      [
        ("int_lst", IntList [ 1 ]);
        ("learning_rate", Float 1.0);
        ("str_lst", StringList [ "1" ]);
        ("style_weight", Int 1);
      ];
    flags_test "1 flag provided" cmd2
      [
        ("int_lst", IntList [ 1 ]);
        ("learning_rate", Float 2.0);
        ("str_lst", StringList [ "1" ]);
        ("style_weight", Int 1);
      ];
    flags_test "4 flag provided" cmd3
      [
        ("int_lst", IntList [ 2344; 10 ]);
        ("learning_rate", Float 2.0);
        ("str_lst", StringList [ "apple"; "banana" ]);
        ("style_weight", Int 10);
      ];
    parse_fail_flag "invalid flag causes parsing to fail" "d" "d"
      "-foo 10" "foo";
    parse_fail_flag "invalid flag causes parsing to fail" "d" "d"
      "-learning_rate 2.0 -foo 10" "foo";
    parse_fail_type "wrong type causes parsing to fail" "d" "d"
      "-learning_rate \"123\"";
  ]

let suite = "test suite for A2" >::: List.flatten [ command_tests ]
let _ = run_test_tt_main suite
