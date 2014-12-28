(* Basic Shannon Entropy calculator in generic OCaml
 * uses a mutable Hashtbl 
 * supports both string and file inputs *)


(* --- calculation support section --- *)

(* pre-bake and return an inner-loop function to do the binning and assembly
   of a character frequency map
*)
let get_fproc (m: (char, int) Hashtbl.t) :(char -> unit)  =

  (fun (c:char) -> try
               Hashtbl.replace m c ( (Hashtbl.find m c) + 1) 
             with Not_found -> Hashtbl.add m c 1)



(* pre-bake and return an inner-loop function to do the actual entropy calculation *)
let get_calc (slen:int) :(float -> float) = 
  let slen_float = float_of_int slen in
  let log_2 = log 2.0 in

  (fun v -> let pt = v /. slen_float in
                pt *. ((log pt) /. log_2) )



(* Given a character frequency map, calculate the Shannon Entropy (in bits):
 * -> extract a list of relative probabilites from the frequency map
 *    fold-in the entropy calculation
 *    return a tuple with result, source length and alphabet size 
 *)
let calculate_entropy (freq_hash: ('a, int) Hashtbl.t) :(int * int * float) =

  let relative_probs = Hashtbl.fold (fun k v b -> (float v)::b) freq_hash [] in
  let slen = List.fold_left (fun b x -> b + (int_of_float x)) 0 relative_probs in
  let calc = get_calc  slen in
  let result = -1.0 *. List.fold_left (fun b x -> b +. calc x) 0.0 relative_probs in

  (slen, (List.length relative_probs), result)



(* --- IO section --- *)

(* Produce a stream of lines from an input source *) 
let lines_of_channel (channel: in_channel) :string Stream.t =
  Stream.from
    (fun _ -> try 
                Some (input_line channel) 
              with End_of_file -> None)


let initial_alphabet_size = 255
 

(* handle the case of string input *)
let shannon_of_string (s:string) :(int * int * float) = 

  let fhash = Hashtbl.create initial_alphabet_size in
  Stream.iter (get_fproc fhash) (Stream.of_string s);
  calculate_entropy fhash


(* handle the case of file input *) 
let shannon_of_filestream (fname:string) :(int * int * float) =

  let fhash = Hashtbl.create initial_alphabet_size in
  let in_ch = open_in fname in
    try 
      Stream.iter (fun line -> String.iter (get_fproc fhash) line )  
                  (lines_of_channel in_ch);

      close_in  in_ch;
      calculate_entropy fhash;
    with e -> raise e 


let get_help_text =
  "Calculate Shannon Entropy (in bits): Usage and Options: \n\n  call with string input or:\n"


(* display ops *)
let show_results ((slen:int), (asize:int), (result:float)) :unit =
   print_endline ("\ncharacter count: " ^ (string_of_int slen));
   print_endline ("alphabet size: " ^ (string_of_int asize));
   print_endline ("value: " ^ (string_of_float result));
   print_endline ""



(* --- main section --- *)

(* modes of operation *)
type run_mode = FileStream of string | StringStream 


(* use a local run mode ref, written only by the (one-time) command line parser.
  generic Arg usage 
*)
let () =
  let run_env = ref StringStream in
  let set_fs_run_env x = run_env := FileStream(x) in

  let speclist = [("", Arg.String (set_fs_run_env), (get_help_text));
                  ("-f", Arg.String (set_fs_run_env), "read from a specified file\n"); ] in
  Arg.parse speclist (fun a -> ()) "" ;

  match !run_env with
    FileStream(fname) -> show_results(shannon_of_filestream fname)
  | StringStream -> if (Array.length Sys.argv == 2)
                    then show_results(shannon_of_string Sys.argv.(1))
;;



