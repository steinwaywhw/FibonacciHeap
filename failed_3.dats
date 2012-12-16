

(****** NODE AND OBJECT TYPES ******)

absviewtype object_t (a: viewt@ype+)
assume object_t (a: viewt@ype) = 
	[l: addr | l > null] @{at = a@l, gc = free_gc_v (a?, l), ptr = ptr (l)}

absviewtype node_t (a: t@ype+)

viewtypedef node_struct (a: t@ype) =
	@{key = a, degree = int, marked = bool, parent = node_t (a), child = node_t (a), left = node_t (a), right = node_t (a)}

dataviewtype node_option_t (a: t@ype+, b: bool) = 
	| node_null (a, false) of ()
	| node_cons (a, true) of (object_t (node_struct (a)))

assume node_t (a: t@ype) = [b: bool] node_option_t (a, b)

viewtypedef node_0 (a: t@ype) = node_option_t (a, false)
viewtypedef node_1 (a: t@ype) = node_option_t (a, true)

(****** OBJECT FUNCTIONS ******)

extern fun {a: viewt@ype} 
object_new (): object_t (a?)

extern fun 
object_free {a: viewt@ype} (x: object_t (a?)): void

extern fun 
object_init {a: viewt@ype} (x: !object_t (a?) >> object_t (a), f: (&a? >> a) -> void): void

extern fun 
object_clear {a: viewt@ype} (x: !object_t (a) >> object_t (a?), f: (&a >> a?) -> void): void


implement {a} 
object_new () = let 
	val (pf_gc, pf_at | p) = ptr_alloc<a> ()
in
	@{at = pf_at, gc = pf_gc, ptr = p}
end

implement 
object_free {a} (x) = ptr_free (x.gc, x.at | x.ptr)

implement 
object_init {a} (x, f) = let 
	prval pf_at = x.at
	val () = f (!(x.ptr))
	prval () = x.at := pf_at
in
end

implement 
object_clear {a} (x, f) = let 
	prval pf_at = x.at
	val () = f (!(x.ptr))
	prval () = x.at := pf_at
in
end

(****** NODE FUNCTIONS ******)

extern fun {a: t@ype} node_make (key: a): node_1 (a)
extern fun {a: t@ype} node_free (node: node_1 (a)): a

extern fun {a: t@ype} node_set_key (node: !node_1 (a), key: a): void
extern fun {a: t@ype} node_get_key (node: !node_1 (a)): a
extern fun {a: t@ype} node_set_parent (node: !node_1 (a), parent: !node_t (a)): void
extern fun {a: t@ype} node_get_parent (node: !node_1 (a)): node_t (a)

implement {a} 
node_make (key) = let 
	fn f (x: &node_struct (a)? >> node_struct (a)): void = let 
		val () = x.key := key
		val () = x.degree := 0
		val () = x.marked := false
		val () = x.parent := node_null ()
		val () = x.left := node_null ()
		val () = x.right := node_null ()
		val () = x.child := node_null ()
	in 
	end

	val x = object_new<node_struct (a)> ()
	val () = object_init {node_struct (a)} (x, f)
in
	node_cons (x)
end

implement {a} 
node_free (node) = let
	val node_cons (obj) = node
	prval pf_at = obj.at
	val key = obj.ptr->key
	val () = obj.at := pf_at
	fn f (x: &node_struct (a) >> node_struct (a)?): void = let 
		val () = x.key := key
		val () = x.degree := 0
		val () = x.marked := false
		val () = x.parent := node_null ()
		val () = x.left := node_null ()
		val () = x.right := node_null ()
		val () = x.child := node_null ()
	in 
	end
	val () = object_clear {node_struct (a)} (obj, f)
	val () = object_free {node_struct (a)} (obj)
in
	key
end

////
implement {a} node_get_key (node) = let 
	val node_cons (obj) = node
	prval pf_at = obj.at
	val key = obj.ptr->key
	val () = obj.at := pf_at
in 
	key
end


////
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
