

datatype node_t (a: t@ype+, b: t@ype+) = 
	| node_null (a, b) of ()
	| {n:nat} node_cons (a, b) of (a, b, node_t (a, b), node_t (a, b), node_t (a, b), node_t (a, b), int (n), bool)

datatype degree_node_t (a: t@ype+, b: t@ype+) = 
	| degree_node_null (a, b) of ()
	| degree_node_cons (a, b) of (node_t (a, b), degree_node_t (a, b))

datatype degree_array_t (a: t@ype+, b: t@ype+, degree: int) =
	| degree_array_null (a, b, ~1) of ()
	| {n: nat} degree_array_cons (a, b, n) 
		of (degree_node_t (a, b), degree_array_t (a, b, n-1))

datatype heap_t (a: t@ype+, b: t@ype+) = 
	| heap_null (a, b) of ()
	| {n: nat} heap_cons (a, b) 
		of (node_t (a, b), node_t (a, b), degree_array_t (a, b, 45), int (n))

fun {a, b: t@ype} 
node_set_left (node: &node_t (a, b) >> node_t (a, b), left: node_t (a, b)): node_t (a, b) = let
	node_cons (data, key, parent, child, old_left, right, degree, marked)- = node
	val () = node := node_cons (data, key, parent, child, left, right, degree, marked)
in
	old_left
end

fun {a, b: t@ype} 
node_set_right (node: &node_t (a, b) >> node_t (a, b), right: node_t (a, b)): node_t (a, b) = let
	node_cons (data, key, parent, child, left, old_right, degree, marked)- = node
	val () = node := node_cons (data, key, parent, child, left, right, degree, marked)
in
	old_right
end

fun {a, b: t@ype} 
node_set_parent (node: &node_t (a, b) >> node_t (a, b), parent: node_t (a, b)): node_t (a, b) = let
	node_cons (data, key, old_parent, child, left, right, degree, marked)- = node
	val () = node := node_cons (data, key, parent, child, left, right, degree, marked)
in
	old_parent
end

fun {a, b: t@ype} 
node_set_chlid (node: &node_t (a, b) >> node_t (a, b), child: node_t (a, b)): node_t (a, b) = let
	node_cons (data, key, parent, old_child, left, right, degree, marked)- = node
	val () = node := node_cons (data, key, parent, child, left, right, degree, marked)
in
	old_child
end


////
fun {a, b: t@ype} 
insert_into_roots (heap: &heap_t (a, b) >> heap_t (a, b), node: node_t (a, b)): void

implement {a, b} insert_into_roots (heap, node) = let
	heap_t (old_root, min, degrees, count)- = heap
	val _ = node_set_right (node, old_root)
	val _ = node_set_left (old_root, node)
	val () = heap := heap_cons (node, min, degrees, count)
in
end