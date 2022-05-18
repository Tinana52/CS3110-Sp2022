val normalize : Torch.Tensor.t -> Torch.Tensor.t
(** [normalize tensor] returns normalized tensor with ImageNet mean and
    standard deviation. Warning: This is copied from OCaml-Torch source
    code, see LOC.txt *)

val unnormalize : Torch.Tensor.t -> Torch.Tensor.t
(** [unnormalize tensor] returns unnormalized tensor from the normalized
    tensor, with ImageNet mean and standard deviation. Warning: This is
    copied from OCaml-Torch source code, see LOC.txt *)

val output_tensor : Torch.Tensor.t -> Torch.Tensor.t
(** [output_tensor tensor] returns unnormalized tensor from the normalized
    tensor, with ImageNet mean and standard deviation. Warning: This is
    copied from OCaml-Torch source code, see LOC.txt *)

val get_shape_str : Torch.Tensor.t -> string
val get_img_size_height : Torch.Tensor.t -> int
val get_img_size_width : Torch.Tensor.t -> int
val print_shape : Torch.Tensor.t -> unit
val read_img_to_tensor : string -> Torch.Tensor.t
val read_img_to_tensor_reshape : string -> int * int -> Torch.Tensor.t
