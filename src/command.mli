exception Invalid_Flag of string
(** Raised when a wrong flag is encountered. *)

exception TypeMismatch
(** Raised when a wrong flag type is encountered. *)

(** The type [flag_type] represents the type of a flag argument. *)
type flag_type =
  | Int of int
  | Float of float
  | String of string
  | IntList of int list
  | FloatList of float list
  | StringList of string list

type command
(** The type [command] includes data about the content image, style
    image, and optional arguments. *)

val all_flags : string list
(** [all_flags] is the list of all possible optional argument names. *)

val parse_command : string -> string -> string -> string -> command
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

val get_flags : command -> (string * flag_type) list
(** [get_style cmd] returns the value of all flags in [cmd] as an
    association list. Each element is in the format of [(name,value)]. *)
