

typedef int bool;

#define true 1
#define false 0
#define DEGREE_ARRAY_SIZE 45

typedef struct node_t {
	void *data;
	void *key;
	struct node_t *parent, *child, *left, *right;
	int degree;
	bool marked;
	int (*compare) (struct node_t *a, struct node_t *b);
} node_t;

typedef struct degree_node_t {
	node_t *node;
	struct degree_node_t *next
} degree_node_t;

typedef struct fibonacci_heap_t {
	node_t *min;
	node_t *root;
	degree_node_t *degree_array[DEGREE_ARRAY_SIZE];
	unsigned int count;
} fibonacci_heap_t;

bool is_empty (fibonacci_heap_t *heap);
void* delete_min (fibonacci_heap_t *heap);
void decrease_key (fibonacci_heap_t *heap, node_t *node, void *key);
node_t* insert (fibonacci_heap_t *heap, void *data, void *key);

fibonacci_heap_t* create_fibonacci_heap ();
void destroy_fibonacci_heap (fibonacci_heap_t *heap);
void set_compare (int (*compare)(node_t*, node_t*));
void traverse (fibonacci_heap_t *heap, void (*visit)(fibonacci_heap_t *heap, node_t *node, void *arg), void *arg);

int _key_compare (node_t *node, void *key);
int _compare_int (node_t *a, node_t *b);
void _insert_into_degrees (fibonacci_heap_t *heap, node_t *node);
void _remove_from_degrees (fibonacci_heap_t *heap, node_t *node);
int _insert_into_roots (fibonacci_heap_t *heap, node_t *node);
int _remove_from_roots (fibonacci_heap_t *heap, node_t *node);
node_t* _insert_into_children (node_t *parent, node_t *child);
int _remove_from_children (node_t *child);
int _update_min (fibonacci_heap_t *heap, node_t *node);
void _consolidate (fibonacci_heap_t *heap);
void _cut (fibonacci_heap_t *heap, node_t *subroot);
void _do_traverse (fibonacci_heap_t *heap, node_t *subroot, void (*visit)(fibonacci_heap_t *heap, node_t *node, void *arg), void *arg);

void _visit_dot (fibonacci_heap_t *heap, node_t *node, void *arg);
void _dot (fibonacci_heap_t *heap);