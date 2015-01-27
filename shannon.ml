(* 
  Basic Shannon Entropy calculator in generic OCaml 
  Handles both string and File input sources
*)



(* IO: all display ops are contained here *)
let show_results ((slen:int), (asize:int), (result:float)) :unit =

   print_endline ("\ncharacter count: " ^ (string_of_int slen));
   print_endline ("value: " ^ (string_of_float result));
   print_endline "-------"



(* for string inputs: 
   pre-bake and return an inner-loop function to do the binning 
   and assembly of a character frequency map 
 
   uses a Hashtbl for the bins 
*)
let get_string_processor (m: (char, int) Hashtbl.t) :(char -> unit)  =
  (fun (c:char) -> try
               Hashtbl.replace m c ( (Hashtbl.find m c) + 1) 
             with Not_found -> Hashtbl.add m c 1)



(* for file inputs: 
   pre-bake and return an inner-loop function to do the binning 
   and assembly of a character frequency map 
 
   uses a mutable array for the bins 
*)
let get_array_processor (m: int array) :(char -> unit)  =
  (fun (c:char) -> m.(int_of_char(c)) <- m.(int_of_char(c)) + 1;)



(* pre-bake and return an inner-loop function to do the actual entropy calculation *)
let get_calc (slen:int) :(float -> float) = 
  let slen_float = float_of_int slen in
  let log_2 = log 2.0 in

  (fun v -> let pt = v /. slen_float in
                pt *. ((log pt) /. log_2) )



(* Hashtbl version: Given a character frequency map, calculate the Shannon Entropy *)
let calculate_entropy_hashtbl (freq_hash: ('a, int) Hashtbl.t) :(int * int * float) =

  let relative_probs = Hashtbl.fold (fun k v b -> (float v)::b) freq_hash [] in
  let slen = List.fold_left (fun b x -> b + (int_of_float x)) 0 relative_probs in
  let calc = get_calc  slen in
  let result = -1.0 *. List.fold_left (fun b x -> b +. calc x) 0.0 relative_probs in

  (slen, (List.length relative_probs), result)



(* Array version: Given a character frequency map, calculate the Shannon Entropy *)
let calculate_entropy_array (freq_array: int array) :(int * int * float) =

  let slen = Array.fold_left (fun b x -> b + x ) 0 freq_array in
  let calc = get_calc  slen in
  let result = -1.0 *. Array.fold_left 
                         (fun a b -> if (b = 0) then a 
                                     else a +. calc (float_of_int(b)) ) 0.0 freq_array in

  (slen, (Array.length freq_array), result)



(* handle the case of string input *)
let shannon_of_string (s:string) : ('a, int) Hashtbl.t   = 

  let fhash = Hashtbl.create 256 in
  Stream.iter (get_string_processor fhash) (Stream.of_string s);
  fhash




(* handle file input via char reads.  includes newline chars.  *)
let shannon_of_filestream (fname:string)  : int array =

  let farray = Array.make 256 0 in 

  (* yeah, that buffer size is just a gratuitous magic number *)
  let bufsize = 2000 in

  let buf = String.make bufsize '0' in
  let running = ref true in 

  let in_chan = open_in fname in
    try

      while !running do
        let n = (input in_chan buf 0 bufsize) in
          if n > 0 then
            String.iter (get_array_processor farray) (String.sub buf 0 n)
          else running := false
      done;

    close_in in_chan; 
    farray;

    with e -> begin
               close_in in_chan; 
               farray
              end




(* modes of operation *)
type run_mode = FileStream of string | StringStream 


(* use a local run mode ref, written only by the (one-time) command line parser.
 * generic Arg usage *)
let () =

  let run_env = ref StringStream in
  let set_fs_run_env x = run_env := FileStream(x) in

  let speclist = [("-f", Arg.String (set_fs_run_env), "filename \n");] in
  Arg.parse speclist (fun a -> ()) "";

  match !run_env with
    FileStream(fname) -> show_results( 
                              calculate_entropy_array( 
                                shannon_of_filestream fname))

  | StringStream -> if (Array.length Sys.argv == 2)
                    then show_results(
                              calculate_entropy_hashtbl( 
                                shannon_of_string Sys.argv.(1)))
                    else print_endline("\nusage: shannon somestring \nor:    shannon -f filename\n");
;;



