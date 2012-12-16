

staload UN = "prelude/SATS/unsafe.sats"

(****** CAST ******)
extern castfn ptr1_of_ptr (p: ptr):<> [l:addr] ptr l

(****** OBJECT ******)

absviewtype object (a: viewt@ype+)
assume object (a: viewt@ype) = [l:addr] @{at = a@l, gc = free_gc_v (a?, l), ptr = ptr (l)}

extern fun {a: viewt@ype} object_new (): object (a?)
extern fun object_free {a: viewt@ype} (x: object (a?)): void
extern fun object_init {a: viewt@ype} (x: !object (a?) >> object (a), f: (&a? >> a) -> void): void
extern fun object_clear {a: viewt@ype} (x: !object (a) >> object (a?), f: (&a >> a?) -> void): void

implement {a} object_new () = let 
	val (pf_gc, pf_at | p) = ptr_alloc<a> ()
in
	@{at=pf_at, gc=pf_gc, ptr=p}
end

implement object_free {a} (x) = ptr_free (x.gc, x.at | x.ptr)

implement object_init {a} (x, f) = let 
	prval pf_at = x.at
	val () = f (!(x.ptr))
	prval () = x.at := pf_at
in
end

implement object_clear {a} (x, f) = let 
	prval pf_at = x.at
	val () = f (!(x.ptr))
	prval () = x.at := pf_at
in
end


	
(****** NODE ******)

absviewtype node_t (a: t@ype)
viewtypedef node_struct (a: t@ype) = 
	@{key=a, degree=int, marked=bool, parent=node_t(a), child=node_t(a), left=node_t(a), right=node_t(a)}
assume node_t (a: t@ype) = object (node_struct (a))
////
extern fun {a: t@ype} node_make (key: a): node_t (a)
extern fun {a: t@ype} node_free (node: node_t (a)): a

extern fun {a: t@ype} node_set_key (node: !node_t (a), key: a): void
extern fun {a: t@ype} node_get_key (node: !node_t (a)): a
extern fun {a: t@ype} node_set_parent (node: !node_t (a), parent: !node_t (a)): void
extern fun {a: t@ype} node_get_parent {l:addr} (pf: !node_t (a) @ l | node: !node_t (a)): node_t (a)
extern fun {a: t@ype} node_set_child (node: !node_t (a), key: a): void
extern fun {a: t@ype} node_get_child (node: !node_t (a), key: a): void


implement {a} node_make (key) = let 
	fn f (x: &node_struct (a)? >> node_struct (a)): void = let 
		val () = x.key := key
		val () = x.degree := 0
		val () = x.marked := false
		val () = x.parent := null
		val () = x.left := null
		val () = x.right := null
		val () = x.child := null
	in 
	end

	val x = object_new<node_struct (a)> ()
	val () = object_init {node_struct (a)} (x, f)
in
	x
end

implement {a} node_free (node) = let
	prval pf_at = node.at
	val key = node.ptr->key
	val () = node.at := pf_at
	val () = object_free {node_struct (a)} (node)
in 
	key
end

implement {a} node_get_key (node) = let 
	prval pf_at = node.at
	val key = node.ptr->key
	val () = node.at := pf_at
in 
	key
end

implement {a} node_set_key (node, key) = let 
	prval pf_at = node.at
	val () = node.ptr->key := key 
	val () = node.at := pf_at
in 
end

implement {a} node_set_parent (node, parent) = let 
	prval pf_at = node.at
	val () = node.ptr->parent := parent.ptr
	val () = node.at := pf_at
in 
end

implement {a} node_get_parent {l} (pf | node) = let 
	prval pf_at = node.at 
	val parent_ptr = ptr1_of_ptr (node.ptr->parent)
	val parent = ptr_get_vt<node_t (a)> (pf | parent_ptr)
	val () = node.at := pf_at
in
	parent 
end


implement main () = let 
	val node = node_make ("string")
	var key : string
	val () = node_free (node, key)
in 
end 

////
abstype node_t (key_t: viewt@ype+, l: addr)
typedef node_t_0 (key_t: viewt@ype) = [l:addr | l >= null] node_t (key_t, l)
typedef node_t_1 (key_t: viewt@ype) = [l:addr | l > null] node_t (key_t, l)

dataviewtype heap_t (key_t: viewt@ype+) = heap (key_t) of (node_t_0 (key_t), int)

viewtypedef node_struct (key_t: t@ype) =
	@{key=key_t, degree=int, marked=bool, parent=ptr, child=ptr, left=ptr, right=ptr}


extern
castfn {key_t: t@ype} 
cast_from_node (node: node_t_1 (key_t)):<> 
	[l:addr | l>null] (free_gc_v (key_t, l), node_struct (key_t) @ l| ptr l)

(* extern
castfn {key_t: t@ype}
cast_from_node (node: node_t_1 (key_t)):<> 
	[l:addr | l>null] (node_struct (key_t) @ l, node_struct (key_t) @l -<lin, prf> void | ptr l)
 *)
fun {key_t: t@ype} node_make (key: key_t) : node_t_1 (key_t) = let
	val (pf_gc, pf_type | p) = ptr_alloc<node_struct(key_t)> ()
	val () = p->key := key
	val () = p->degree := 0
	val () = p->marked := false
	val () = p->parent := null
	val () = p->left := null
	val () = p->right := null
	val () = p->child := null
in
	$UN.castvwtp_trans {node_t_1 (key_t)} (@(pf_gc, pf_type | p))
end

fun {key_t: t@ype} node_free (node: node_t_1 (key_t), key: &key_t? >> key_t): void = let 
	prval (pf_gc, pf_type | p) = cast_from_node (node)
	val () = key := p->key
	val () = ptr_free (pf_gc, pf_type | p)
in
end

fun {key_t: t@ype} node_get_key (node: node_t_1 (key_t)): key_t = let
	val (pf, fpf | p) = cast_from_node (node)
