


%{^
#include <malloc.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#define MAX_DEGREE 45

typedef struct node_t {
	int key;
	struct node_t *parent, *child, *left, *right;
	int degree;
	int marked;
} node_t;

typedef struct heap_t {
	node_t *min, *root;
	int count;
} heap_t;

node_t* node_make (int key) {
	node_t *node = (node_t *) malloc (sizeof (node_t));
	memset (node, 0, sizeof (node_t));
	node->key = key;
	return node;
}

int node_free (node_t *node) {
	int key = node->key;
	free (node);
	return key;
}

node_t* node_null () {return NULL;}

heap_t* heap_make () {
	heap_t *heap = (heap_t *) malloc (sizeof (heap_t));
	memset (heap, 0, sizeof (heap));
	return heap;
}

void heap_free (heap_t *heap) {
	free (heap);
}

int node_get_key (node_t *node) {return node->key;}
void node_set_key (node_t *node, int key) {node->key = key;}
node_t* node_get_parent (node_t *node) {return node->parent;}
void node_set_parent (node_t *node, node_t *parent) {node->parent = parent;}
node_t* node_get_child (node_t *node) {return node->child;}
void node_set_child (node_t *node, node_t *child) {node->child = child;}
node_t* node_get_left (node_t *node) {return node->left;}
void node_set_left (node_t *node, node_t *left) {node->left = left;}
node_t* node_get_right (node_t *node) {return node->right;}
void node_set_right (node_t *node, node_t *right) {node->right = right;}
int node_get_degree (node_t *node) {return node->degree;}
void node_set_degree (node_t *node, int degree) {node->degree = degree;}

void node_mark (node_t *node) {node->marked = 1;}
void node_unmark (node_t *node) {node->marked = 0;}
int node_is_marked (node_t *node) {return node->marked == 1;}
int node_is_null (node_t *node) {return node == NULL;}
int node_is_equal (node_t *a, node_t *b) {return a == b;}

node_t* heap_get_min (heap_t *heap) {return heap->min;}
void heap_set_min (heap_t *heap, node_t *node) {heap->min = node;}
node_t* heap_get_root (heap_t *heap) {return heap->root;}
void heap_set_root (heap_t *heap, node_t* node) {heap->root = node;}
int heap_get_count (heap_t *heap) {return heap->count;}
void heap_set_count (heap_t *heap, int count) {heap->count = count;}

node_t** degree_array_make () {
	node_t **array = (node_t **) malloc (sizeof (node_t *) * MAX_DEGREE);
	memset (array, 0, sizeof (node_t *) * MAX_DEGREE);
	return array;
}

void degree_array_free (node_t **array) {
	free (array);
}

node_t* degree_array_get (node_t **array, int index) {return array[index];}
void degree_array_set (node_t **array, int index, node_t *node) {array[index] = node;}

void debug_node (node_t *node) {
	int parent = node->parent == NULL ? -1 : node->parent->key;
	int child = node->child == NULL ? -1 : node->child->key;
	int left = node->left == NULL ? -1 : node->left->key;
	int right = node->right == NULL ? -1 : node->right->key;

	printf ("%d[%d, %d, %d, %d]\n", node->key, parent, child, left, right);
}

void _visit_dot (heap_t *heap, node_t *node, void *arg) {

	int fd = (int)arg;

	char buffer[128];
	sprintf (buffer, "\"%p\" [shape=%s, label=%u, color=%s, style=%s]\n", node, "box", node->key, "grey", "filled");
	write (fd, buffer, strlen (buffer));


	if (node->child != NULL) {
		sprintf (buffer, "\"%p\" -> \"%p\"\n", node, node->child);
		write (fd, buffer, strlen (buffer));
	}
	if (node->parent != NULL) {
		sprintf (buffer, "\"%p\" -> \"%p\"\n", node, node->parent);
		write (fd, buffer, strlen (buffer));
	}
	if (node->left != NULL) {
		sprintf (buffer, "\"%p\" -> \"%p\"\n", node, node->left);
		write (fd, buffer, strlen (buffer));
	}
	if (node->right != NULL) {
		sprintf (buffer, "\"%p\" -> \"%p\"\n", node, node->right);
		write (fd, buffer, strlen (buffer));
		sprintf (buffer, "{rank = same; \"%p\"; \"%p\"}\n", node, node->right);
		write (fd, buffer, strlen (buffer));
	}
}

int _debug_heap_pre () {
	int fd = open ("./graph", O_RDWR | O_CREAT | O_TRUNC, 0644);
	char *header = "strict digraph fibonacci_heap {\n";
	write (fd, header, strlen (header));

	return fd;
}

void _debug_heap_post (int fd) {
	char *footer = "ranksep = 1;\nnodesep = 1;\n}\n";
	write (fd, footer, strlen (footer));

	fsync (fd);
	close (fd);
}

void* _int_to_void_ptr (int fd) {return (void*)fd;}

%}

typedef node_t = $extype "node_t *"
typedef heap_t = $extype "heap_t *"
typedef degree_array_t = $extype "node_t **"

extern fun node_make (key: int): node_t = "node_make"
extern fun node_free (node: node_t): int = "node_free"
extern fun node_null (): node_t = "node_null"
extern fun node_get_key (node: !node_t): int = "node_get_key"
extern fun node_set_key (node: !node_t, key: int): void = "node_set_key"
extern fun node_get_parent (node: !node_t): node_t = "node_get_parent"
extern fun node_set_parent (node: !node_t, parent: node_t): void = "node_set_parent"
extern fun node_get_child (node: !node_t): node_t = "node_get_child"
extern fun node_set_child (node: !node_t, child: node_t): void = "node_set_child"
extern fun node_get_left (node: !node_t): node_t = "node_get_left"
extern fun node_set_left (node: !node_t, left: node_t): void = "node_set_left"
extern fun node_get_right (node: !node_t): node_t = "node_get_right"
extern fun node_set_right (node: !node_t, right: node_t): void = "node_set_right"
extern fun node_get_degree (node: !node_t): int = "node_get_degree"
extern fun node_set_degree (node: !node_t, degree: int): void = "node_set_degree"

extern fun node_mark (node: !node_t): void = "node_mark"
extern fun node_unmark (node: !node_t): void = "node_unmark"
extern fun node_is_marked (node: !node_t): bool = "node_is_marked"
extern fun node_is_null (node: !node_t): bool = "node_is_null"
extern fun node_is_equal (a: !node_t, b: !node_t): bool = "node_is_equal"

extern fun heap_make (): heap_t = "heap_make"
extern fun heap_free (heap: heap_t): void = "heap_free"
extern fun heap_get_min (heap: !heap_t): node_t = "heap_get_min"
extern fun heap_set_min (heap: !heap_t, node: node_t): void = "heap_set_min"
extern fun heap_get_root (heap: !heap_t): node_t = "heap_get_root"
extern fun heap_set_root (heap: !heap_t, node: node_t): void = "heap_set_root"
extern fun heap_get_count (heap: !heap_t): int = "heap_get_count"
extern fun heap_set_count (heap: !heap_t, count: int): void = "heap_set_count"

extern fun degree_array_make (): degree_array_t = "degree_array_make"
extern fun degree_array_free (array: degree_array_t): void = "degree_array_free"
extern fun degree_array_set (array: !degree_array_t, index: int, node: !node_t): void = "degree_array_set"
extern fun degree_array_get (array: !degree_array_t, index: int): node_t = "degree_array_get"

extern fun heap_is_empty (heap: !heap_t): bool
extern fun key_compare (a: int, b: int): int
extern fun insert (heap: !heap_t, key: int): node_t
extern fun delete_min (heap: !heap_t): int 
extern fun get_min (heap: !heap_t): node_t 
extern fun merge (a: !heap_t, b: !heap_t): heap_t

extern fun _insert_into_roots (heap: !heap_t, node: !node_t): void
extern fun _remove_from_roots (heap: !heap_t, node: !node_t): void
extern fun _update_min (heap: !heap_t, node: !node_t): void
extern fun _insert_into_children (parent: !node_t, child: !node_t): void
extern fun _remove_from_children (child: !node_t): void
extern fun _consolidate (heap: !heap_t): void

typedef visit_func_t = (!heap_t, !node_t, ptr) -> void
extern fun traverse (heap: !heap_t, f: visit_func_t, arg: ptr): void
extern fun debug_node (node: !node_t): void = "debug_node"
extern fun debug_heap (heap: !heap_t): void 
extern fun _debug_heap_pre (): int = "_debug_heap_pre"
extern fun _debug_heap_post (fd: int): void = "_debug_heap_post"

extern fun _int_to_void_ptr (fd: int): ptr = "_int_to_void_ptr"


(***** IMPLEMENTATION *****)
implement get_min (heap) = heap_get_min (heap)

implement merge (a, b) = heap where {

	val a_root = heap_get_root (a)
	val b_root = heap_get_root (b)

	val () = node_set_right (node_get_left (b_root), node_get_right (a_root))
	val () = node_set_right (a_root, b_root)

	val () = node_set_left (node_get_right (a_root), node_get_left (b_root))
	val () = node_set_left (b_root, a_root)

	var heap = a
}




implement debug_heap (heap) = () where {
	extern fun visit (heap: !heap_t, node: !node_t, arg: ptr): void = "_visit_dot"
	val fd = _debug_heap_pre ()
	val () = traverse (heap, visit, _int_to_void_ptr (fd))
	val () = _debug_heap_post (fd)
}


implement traverse (heap, f, arg) = () where {

	fun loop_child (heap: !heap_t, subroot: !node_t, f: visit_func_t, arg: ptr):<cloref1> void =
		if node_is_null (subroot) then () else () where {
			val () = f (heap, subroot, arg)
			val () = loop_child (heap, node_get_child (subroot), f, arg)
			val () = loop_right (heap, node_get_right (subroot), subroot, f, arg)
		}

	and loop_right (heap: !heap_t, current: !node_t, start: !node_t, f: visit_func_t, arg: ptr):<cloref1> void = 
		if node_is_equal (current, start) then () else () where {
			val () = f (heap, current, arg)
			val () = loop_right (heap, node_get_right (current), start, f, arg)
			val () = loop_child (heap, node_get_child (current), f, arg)
		}

	val () = loop_child (heap, heap_get_root (heap), f, arg)
	val () = loop_right (heap, node_get_right (heap_get_root (heap)), heap_get_root (heap), f, arg)
}





implement key_compare (a, b) = a - b

implement heap_is_empty (heap) = let
	val count = heap_get_count (heap)
in
	if count = 0 then true else false
end

(* node, heap->root, node->left->right, node->right->left may be updated *)
implement _insert_into_roots (heap, node) = () where {

	(* parent should be null *)
	val () = node_set_parent (node, node_null ())

	(* heap is empty, then heap->root = node *)
	val () = if heap_is_empty (heap) then () where {
		val () = heap_set_root (heap, node)
		val () = node_set_left (node, node)
		val () = node_set_right (node, node)

	(* heap is not empty, then heap->root = node *)
	} else () where {

		(* node->left = root, node->right = root->right *)
		val root = heap_get_root (heap)
		val () = node_set_right (node, node_get_right (root))
		val () = node_set_left (node, root)

		(* node->right->left = node *)
		val () = node_set_left (node_get_right (node), node)

		(* node->left->right = node *)
		val () = node_set_right (node_get_left (node), node)
	}
	val () = print "_insert_into_roots: "
	val () = debug_node (node)	
}

(* node, heap->root, node->left->right, node->right->left may be updated *)
implement _remove_from_roots (heap, node) = () where {

	(* the only node is to be removed, heap->node = null *)
	val () = if heap_get_count (heap) = 1 then () where {
		val () = heap_set_root (heap, node_null ())
		val () = node_set_left (node, node_null ())
		val () = node_set_right (node, node_null ())

	(* else, heap->node = heap->node->right *)
	} else () where {

		val root = heap_get_root (heap)

		(* update heap->root if heap->root = node *)
		val () = if node_is_equal (node, root) then heap_set_root (heap, node_get_right (node))

		(* node->right->left = node->left *)
		val () = node_set_left (node_get_right (node), node_get_left (node))

		(* node->left->right = node->right *)
		val () = node_set_right (node_get_left (node), node_get_right (node))
		
		val () = node_set_right (node, node_null ())
		val () = node_set_left (node, node_null ())
	}

	val () = print "_remove_from_roots: "
	val () = debug_node (node)	

}

implement _update_min (heap, node) = 

	(* heap is empty, then min is node *)
	if heap_is_empty (heap) then 
		heap_set_min (heap, node)

	(* heap is not empty *)
	else 

		(* node is null, do search *)
		if node_is_null (node) then () where {

			(* traverse the double-linked circur list *)
			fun loop (start: !node_t, current: !node_t, min: !node_t):<cloref1> node_t = 

				(* finished *)
				if node_is_equal (start, current) then 
					min 

				(* unfinished, recurse *)
				else 
					if key_compare (node_get_key (current), node_get_key (min)) < 0 then
						loop (start, node_get_right (current), current)
					else
						loop (start, node_get_right (current), min)

			val root = heap_get_root (heap)
			val min = loop (root, node_get_right (root), root)
			val () = heap_set_min (heap, min)
		
		(* node is not null, do compare *)
		} else 
			if key_compare (node_get_key (node), node_get_key (heap_get_root (heap))) < 0 
			then heap_set_min (heap, node) 

implement _insert_into_children (parent, child) = () where {
	
	val () = node_set_parent (child, parent)

	(* parent has no child*)
	val () = if node_is_null (node_get_child (parent)) then () where {
		val () = node_set_child (parent, child)
		val () = node_set_left (child, child)
		val () = node_set_right (child, child)

	(* insert into children list*)
	} else () where {

		(* child->left = oldchild, child->right = oldchild->right *)
		val oldchild = node_get_child (parent)
		val () = node_set_right (child, node_get_right (oldchild))
		val () = node_set_left (child, oldchild)

		(* child->right->left = child *)
		val () = node_set_left (node_get_right (child), child)

		(* child->left->right = child *)
		val () = node_set_right (node_get_left (child), child)
	}

	val () = print "_insert_into_children: "
	val () = debug_node (child)	

}

implement _remove_from_children (child) = () where {
	val parent = node_get_parent (child)
	val () = node_set_parent (child, node_null ())

	(* only one child *)
	val () = if node_get_degree (parent) = 1 then () where {
		val () = node_set_child (parent, node_null ())
		val () = node_set_parent (child, node_null ())
		val () = node_set_left (child, node_null ())
		val () = node_set_right (child, node_null ())

	(* update parent->child *)
	} else () where {

		val oldchild = node_get_child (parent)

		(* child = parent->child, update parent->child = child->right *)
		val () = if node_is_equal (child, oldchild) then node_set_child (parent, node_get_right (child))

		(* child->right->left = child->left *)
		val () = node_set_left (node_get_right (child), node_get_left (child))

		(* node->left->right = node->right *)
		val () = node_set_right (node_get_left (child), node_get_right (child))
		
		val () = node_set_right (child, node_null ())
		val () = node_set_left (child, node_null ())
	}
	val () = print "_remove_from_children: "
	val () = debug_node (child)	

}

implement _consolidate (heap) = () where {
	val array = degree_array_make ()

	(* insert until no same degree *)
	fun do_insert (current: !node_t):<cloref1> void = () where {
		val degree = node_get_degree (current)
		val node = degree_array_get (array, degree)

		(* there's no same degree nodes, insert it, return *)
		val () = if node_is_null (node) then 
			degree_array_set (array, degree, current)
		
		(* there's same degree nodes, retrive, combine, and re-insert *)
		else () where {

			(* retrieve previous one *)
			val () = degree_array_set (array, degree, node_null ())

			(* determine a parent *)
			val parent = if key_compare (node_get_key (current), node_get_key (node)) < 0 
				then current else node
			val child = if node_is_equal (parent, current) then node else current

			(* combine *)
			val () = _remove_from_roots (heap, child)
			val () = heap_set_count (heap, heap_get_count (heap) - 1)
			val () = _insert_into_children (parent, child)
			val () = node_set_degree (parent, degree + 1)

			(* re-insert *)
			val () = do_insert (parent)
		}
	}

	(* traverse all roots *)
	fun traverse (current: !node_t, remain: int):<cloref1> void = 
		(* finished *)
		if remain = 0 then () 

		(* unfinished *)
		else () where {
			(* save next *)
			val next = node_get_right (current)

			(* insert into degrees *)
			val () = do_insert (current)

			(* next *)
			val () = traverse (next, remain - 1)
		}

	val root = heap_get_root (heap)
	val () = traverse (root, heap_get_count (heap))
	val () = degree_array_free (array)
}
		
implement delete_min (heap) = key where {
	val min = heap_get_min (heap)

	(* remove from roots *)
	val () = _remove_from_roots (heap, min)
	val () = heap_set_count (heap, heap_get_count (heap) - 1)

	fun loop (parent: !node_t):<cloref1> void = 
		if node_is_null (node_get_child (parent)) then () else () where {
			val child = node_get_child (parent)

			val () = _remove_from_children (child)
			val () = node_set_degree (parent, node_get_degree (parent) - 1)
			val () = _insert_into_roots (heap, child)

			val () = loop (parent)
		}

	(* melt children into roots *)
	val () = loop (min)

	val () = _consolidate (heap)

	val () = _update_min (heap, node_null ())

	val key = node_free (min)
}


implement insert (heap, key) = node where {
	val node = node_make (key)
	val () = _insert_into_roots (heap, node)
	val () = _update_min (heap, node)
	val () = heap_set_count (heap, heap_get_count (heap) + 1)
}


implement main () = () where {
	val heap = heap_make ()

	fun loop (heap: !heap_t, current: int):<cloref1> void = 
		if current < 10 then () where {
			val _ = insert (heap, current)
			val () = loop (heap, current + 1)
		}
	val () = loop (heap, 0)
	val key = delete_min (heap)


	val heap_2 = heap_make ()
	val () = loop (heap_2, 0)

	val _ = merge (heap, heap_2)

	val () = debug_heap (heap)

	val () = heap_free (heap_2)
	val () = heap_free (heap)
}	