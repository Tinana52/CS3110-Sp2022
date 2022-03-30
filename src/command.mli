exception Invalid_Flag of string
(** Raised when a wrong flag is encountered. *)

exception TypeMismatch
(** Raised when a wrong flag type is encountered. *)

type flags = {
  style_weight : float;
  learning_rate : float;
  total_steps : int;
  layers_style_loss : int list;
  layers_content_loss : int list;
  k : int;
  sigma : float;
  size : float;
}
(** The type [flags] represents the arguments values. *)

type command
(** The type [command] includes data about the content image, style
    image, and optional arguments. *)

val all_flags : string list
(** [all_flags] is the list of all possible optional argument names. *)

val parse_command :
  string -> string -> string -> string -> string -> command
(** [parse_command c s cmd] parses a user's input into a [command]. It
    ignores any unnecessary spaces. Raises [Invalid_Flag] when an
    unexpected flag is encountered. Raises [TypeMismatch] if an optional
    argument has an incorrect type. *)

val flag_info : string -> string
(** [flag_info s] returns the description of the flag [s]. Raises
    [Invalid_Flag] when an unexpected flag is encountered. *)

val get_content : command -> string
(** [get_content cmd] returns the content image location in [cmd]. *)

val get_style : command -> string
(** [get_style cmd] returns the style image location in [cmd]. *)

val get_model : command -> string
(** [get_model cmd] returns the pre-trained model location in [cmd]. *)

val get_all_flags : command -> flags
(** [get_all_flags cmd] returns a tuple of values of all arguments in
    [cmd]. *)

val get_output : command -> string
(** [get_output cmd] returns the user-inputted output file name in
    [cmd]. *)

val default : flags
(** [default] is the default value of all flags read from the .json
    file. *)
