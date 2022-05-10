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
      "-k : int";
      "-layers_content_loss : int list";
      "-layers_style_loss : int list";
      "-learning_rate : float";
      "-sigma : float";
      "-size : float";
      "-style_weight : float";
      "-total_steps : int";
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
  name >:: fun _ -> assert_equal (get_all_flags cmd) expected_output

let output_test name cmd expected_output =
  name >:: fun _ ->
  assert_equal (get_output cmd) expected_output ~printer:Fun.id

let parse_fail_flag name flags inv_flg =
  name >:: fun _ ->
  assert_raises (Invalid_Flag inv_flg) (fun () ->
      parse_make "" "" "" flags "")

let parse_fail_type name flags =
  name >:: fun _ ->
  assert_raises TypeMismatch (fun () -> parse_make "" "" "" flags "")

let default_test =
  "default flag values" >:: fun _ ->
  assert_equal default
    {
      style_weight = 1e6;
      learning_rate = 1e-1;
      total_steps = 180;
      layers_style_loss = [ 0; 2; 5; 7; 10 ];
      layers_content_loss = [ 7 ];
      k = 5;
      sigma = 1.0;
      size = 1.0;
    }

let cmd1 = parse_make "default" "default" "vgg16" "" ""

let cmd2 =
  parse_make "default" "default" "vgg16" "-learning_rate 2.0" "cmd"

let cmd3 =
  parse_make "default" "default" "vgg16"
    "-layers_style_loss [1, 2, 3, 5, 8] -layers_content_loss [2,3] \
     -style_weight 1e7 -learning_rate 10 -total_steps 100"
    "cmd3"

let command_tests =
  [
    all_flags_test;
    (* flag_info_test "info of style_weight" "style_weight" "style
       weight"; flag_info_test "info of learning_rate" "learning_rate"
       "learning rate"; flag_info_test "info of int_lst" "int_lst"
       "int_list"; flag_info_test "info of str_lst" "str_lst"
       "string_list"; *)
    content_test "default content" cmd1 "data/default.jpg";
    style_test "default style" cmd1 "data/default.jpg";
    output_test "default output" cmd1 "data/output/art.png";
    output_test "output file exists" cmd2 "data/output/cmd2.png";
    output_test "customized output" cmd3 "data/output/cmd3.png";
    parse_fail_flag "invalid flag causes parsing to fail" "-foo 10"
      "foo";
    parse_fail_flag "invalid flag causes parsing to fail"
      "-learning_rate 2.0 -foo 10" "foo";
    parse_fail_type "wrong type causes parsing to fail 1"
      "-learning_rate \"123\"";
    parse_fail_type "wrong type causes parsing to fail 2"
      "-learning_rate [1,2,3]";
    parse_fail_type "wrong type causes parsing to fail 3"
      "-learning_rate [1.0]";
    default_test;
  ]

let suite = "test suite for project" >::: List.flatten [ command_tests ]
let _ = run_test_tt_main suite
