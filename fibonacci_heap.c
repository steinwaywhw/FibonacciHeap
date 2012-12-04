



#include "fibonacci_heap.h"
#include <assert.h>
#include <malloc.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

static int (*_compare) (node_t *a, node_t *b);

fibonacci_heap_t* create_fibonacci_heap () {
	fibonacci_heap_t *heap = (fibonacci_heap_t *)malloc(sizeof(fibonacci_heap_t));
	assert (heap != NULL);
	memset (heap, 0, sizeof(fibonacci_heap_t));

	return heap;
}

void destroy_fibonacci_heap (fibonacci_heap_t *heap) {
	assert (heap != NULL);
	free (heap);
}

void _dot (fibonacci_heap_t *heap) {
	assert (heap != NULL);

	int fd = open ("./graph", O_RDWR | O_CREAT | O_TRUNC, 0644);
	char *header = "digraph fibonacci_heap {\n";
	write (fd, header, strlen (header));

	traverse (heap, _visit_dot, (void *)fd);

	char *footer = "}\n";
	write (fd, footer, strlen (footer));

	fsync (fd);
	close (fd);
}


void _visit_dot (fibonacci_heap_t *heap, node_t *node, void *arg) {

	int fd = (int)arg;

	char buffer[128];
	sprintf (buffer, "\"%p\" [shape=%s, label=%u, color=%s, style=%s]\n", node, "box", *((int *)node->key), "grey", "filled");
	write (fd, buffer, strlen (buffer));


	if (node->child != NULL) {
		sprintf (buffer, "\"%p\" -> \"%p\"\n", node, node->child);
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


void traverse (fibonacci_heap_t *heap, void (*visit)(fibonacci_heap_t *heap, node_t *node, void *arg), void *arg) {
	assert (heap != NULL && visit != NULL);

	_do_traverse (heap, heap->root, visit, arg);
}

void _do_traverse (fibonacci_heap_t *heap, node_t *subroot, void (*visit)(fibonacci_heap_t *heap, node_t *node, void *arg), void *arg) {
	
	// recursion ending condition
	if (subroot == NULL)
		return;

	// root first
	(*visit)(heap, subroot, arg);

	// children
	_do_traverse (heap, subroot->child, visit, arg);

	// siblings
	_do_traverse (heap, subroot->right, visit, arg);
}

void set_compare (int (*compare)(node_t*, node_t*)) {
	_compare = compare;
}



int inline _key_compare (node_t *node, void *key) {
	node_t tmp;
	tmp.key = key;
	return node->compare (node, &tmp);
}

int _compare_int (node_t *a, node_t *b) {
	assert (a != NULL && b != NULL);
	return *((int *)a->key) - *((int *)b->key);
}

bool inline is_empty (fibonacci_heap_t *heap) {
	assert (heap != NULL);

	if (heap->count == 0)
		return true;

	return false;
}

node_t* insert (fibonacci_heap_t *heap, void *data, void *key) {

	assert (_compare != NULL);
	assert (heap != NULL && data != NULL && key != NULL);

	node_t *node = (node_t *)malloc(sizeof(node_t));
	assert (node != NULL);

	node->data = data;
	node->key = key;
	node->parent = NULL;
	node->child = NULL;
	node->degree = 0;
	node->marked = false;
	node->compare = _compare;
	node->left = NULL;
	node->right = NULL;

	if (is_empty (heap)) {
		heap->min = node;
		heap->root = node;
	} else {
		// insert into root list
		_insert_into_roots (heap, node);
	}

	// update min
	_update_min (heap, node);

	// insert into degrees
	_insert_into_degrees (heap, node);

	// update count
	heap->count++;

	return node;
}

void _insert_into_degrees (fibonacci_heap_t *heap, node_t *node) {
	assert (heap != NULL && node != NULL && node->parent == NULL);

	int degree = node->degree;
	degree_node_t *current = heap->degree_array[degree];

	degree_node_t *degree_node = (degree_node_t *)malloc(sizeof(degree_node_t));
	assert (degree_node != NULL);
	degree_node->node = node;
	degree_node->next = NULL;

	// empty
	if (current == NULL) {
		heap->degree_array[degree] = degree_node;

	// has same degree
	} else {
		// go to the end
		while (current->next != NULL)
			current = current->next;

		// link
		current->next = degree_node;
	}

	return;
}

void _remove_from_degrees (fibonacci_heap_t *heap, node_t *node) {
	assert (heap != NULL && node != NULL && node->parent == NULL);

	int degree = node->degree;
	degree_node_t *current = heap->degree_array[degree];
	degree_node_t *prev = NULL;

	while (current->node != node) {
		prev = current;
		current = current->next;
	}

	if (prev == NULL)
		heap->degree_array[degree] = current->next;
	else
		prev->next = current->next;

	free (current);

	return;
}

int inline _insert_into_roots (fibonacci_heap_t *heap, node_t *node) {
	assert (heap != NULL && node != NULL);

	node->parent = NULL;

	// empty
	if (is_empty (heap)) {
		heap->root = node;
		node->left = NULL;
		node->right = NULL;
		return 0;
	}

	// non empty
	node->right = heap->root->right;
	node->left = heap->root;

	if (node->right != NULL)
		node->right->left = node;
	if (node->left != NULL)
		node->left->right = node;

	return 0;
}

int inline _remove_from_roots (fibonacci_heap_t *heap, node_t *node) {
	assert (heap != NULL && node != NULL);

	// update root
	if (heap->root == node) 
		heap->root = node->right;
	
	// remove
	if (node->right != NULL)
		node->right->left = node->left;
	if (node->left != NULL) 
		node->left->right = node->right;

	// update node
	node->right = NULL;
	node->left = NULL;

	return 0;
} 

node_t* _insert_into_children (node_t *parent, node_t *child) {
	assert (parent != NULL && child != NULL);
	assert (parent->parent == NULL && child->parent == NULL);

	assert (parent->compare (parent, child) <= 0);
	
	// insert into children list
	child->parent = parent;
	
	// no child
	if (parent->child == NULL) {
		parent->child = child;

	// insert into children list
	} else {
		child->left = parent->child;
		child->right = parent->child->right;
		if (child->left != NULL)
			child->left->right = child;
		if (child->right != NULL)
			child->right->left = child;
	}

	parent->degree++;
	
	return parent;
}

int _remove_from_children (node_t *child) {
	assert (child != NULL && child->parent != NULL);

	node_t *parent = child->parent;

	// update child
	if (parent->child == child)
		parent->child = child->right;

	if (child->left != NULL)
		child->left->right = child->right;
	if (child->right != NULL)
		child->right->left = child->left;

	child->right = NULL;
	child->left = NULL;
	child->parent = NULL;

	parent->degree--;

	return 0;
}

int inline _update_min (fibonacci_heap_t *heap, node_t *node) {
	// empty
	if (is_empty (heap)) {
		assert (node != NULL);
		heap->min = node;
		return true;
	}

	if (node != NULL) {
		if (node->compare (node, heap->min) < 0) {
			heap->min = node;
			return true;
		}

		// not updated;
		return false;
	}

	// do search
	node_t *current = heap->root;
	bool updated = false;
	while (current != NULL) {
		if (current->compare (current, heap->min) < 0) {
			heap->min = current;
			updated = true;
		}
		current = current->right;
	}

	return updated;
}

void* delete_min (fibonacci_heap_t *heap) {
	assert (heap != NULL);
	assert (!is_empty (heap));

	// get the min
	node_t *node = heap->min;

	// remove it from roots and degrees
	_remove_from_roots (heap, node);
	_remove_from_degrees (heap, node);

	// melt children into roots
	node_t *child = node->child;
	while (child != NULL) {
		node_t *next = child->right;
		_insert_into_roots (heap, child);
		child = next;
	}

	// consolidate
	_consolidate (heap);

	// update min
	_update_min (heap, NULL);

	// return
	void *data = node->data;
	free (node);

	heap->count--;

	return data;
}

void _consolidate (fibonacci_heap_t *heap) {
	assert (heap != NULL);

	// traverse degrees
	int i;
	for (i = 0; i < DEGREE_ARRAY_SIZE; i++) {
		degree_node_t *current = heap->degree_array[i];
		while (current != NULL) {
			degree_node_t *next = current->next;
			if (next == NULL)
				break;

			node_t *c = current->node;
			node_t *n = next->node;

			_remove_from_degrees (heap, c);
			_remove_from_degrees (heap, n);

			if (c->compare (c, n) <= 0) {
				_remove_from_roots (heap, n);
				_insert_into_children (c, n);
				_insert_into_degrees (heap, c);
			} else {
				_remove_from_roots (heap, c);
				_insert_into_children (n, c);
				_insert_into_degrees (heap, n);
			}


			current = heap->degree_array[i];
		}
	}
}

void decrease_key (fibonacci_heap_t *heap, node_t *node, void *key) {
	assert (heap != NULL && node != NULL && key != NULL);
	assert (_key_compare (node, key) > 0);

	// decrease
	node->key = key;

	// already root
	if (node->parent == NULL) {
		_update_min (heap, node);
		return;
	}

	// normal decrease
	if (node->parent != NULL && node->compare (node, node->parent) >= 0)
		return;

	// recursive cut
	_cut (heap, node);

}


void _cut (fibonacci_heap_t *heap, node_t *subroot) {
	assert (subroot != NULL && heap != NULL);

	// recursion ending condition
	if (subroot->parent == NULL)
		return;

	node_t *parent = subroot->parent;
	_remove_from_children (subroot);
	_insert_into_roots (heap, subroot);
	_insert_into_degrees (heap, subroot);
	_update_min (heap, subroot);
	subroot->marked = false;

	if (parent->marked == false) {
		parent->marked = true;
		return;
	} 
	
	_cut (heap, subroot->parent);
}


int main () {
	fibonacci_heap_t *heap = create_fibonacci_heap ();
	set_compare (_compare_int);

	int d[100];
	int k[100];
	int i;
	for (i = 0; i < 100; i++) {
		k[i] = i;
		d[i] = i - 10;
	}

	for (i = 0; i < 10; i++) {
		insert (heap, &d[i], &k[i]);
	}

	//_dot (heap);
	//_remove_from_roots (heap, heap->root);
	//_dot (heap);

	// node_t *node = heap->root->right;

	// _remove_from_roots (heap, node);
	// _insert_into_children (heap->root, node);

	// node = heap->root->right;

	// _remove_from_roots (heap, node);
	// _insert_into_children (heap->root, node);

	// _remove_from_children (node);
	// _insert_into_roots (heap, node);
	// _dot (heap);


	delete_min (heap);
	_dot (heap);


	destroy_fibonacci_heap (heap);
}
// fibonacci_heap_t *union (fibonacci_heap_t *a, fibonacci_heap_t *b) {
// 	assert (a != NULL && b != NULL);
// 	node_t *current = a->root;

// 	while (current->right != NULL)
// 		current = current->right;

// 	current->right = b->root;
// 	b->root->left = current;

// 	a->count += b->count;
// 	_update_min (a, NULL);

// 	return a;
// }

