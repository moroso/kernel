/* Memory allocator -- whee ("slab allocator") 
 * a very simple slab allocator.  the basic allocation function 
 * searches a list of sorted, sized "caches" for the bucket size that is the
 * closest fit to the allocation.  
 *
 *   each cache contains a list of elements cut
 * from one or more "slabs": large, contiguous chunks of memory handed to us by
 * the buddy allocator    
 *
 * users can also create caches for memory chunks of uniform size; however, we
 * are not currently preserving struct initialization
 *
 * In order for this to actually work, we will need globals 
 * TODO remove slabs when they are freed
*/

#include "list.mh"
#define SLAB_SIZE 4096 /* this really isn't the right size*/
#define UINT_SIZE 4
#define POWER_MIN 2
#define POWER_MAX 9

fn print_int(x: i32) {}
fn assert(x: bool) {}
fn print_uint(x: u32) { print_int(x as i32); }
fn print_char(x: u32) {}
fn print_newline() { print_char(10); }
fn malloc<T>(i: u32) -> *T { 0 as *T }

#define ERR (print_int(-1))

struct slab_descriptor {
  slab: *u32,
  slab_low: *u32,
  element_count: u32,
  slab_link: list_node,
}

struct cache_descriptor {
  size: u32,
  slab: *u32,
  link: list_node,
}

static head: list_head;
static caches: *cache_descriptor;

fn slab_add(size: u32, cache: *cache_descriptor) {
    let slab: *u32 = malloc(SLAB_SIZE);
    if (slab == null) {
      return (); 
    }
    /* divide into elements */    
    let node_prev: *u32 = slab;
    let i: u32;
    for (i = size; i < SLAB_SIZE; i+=size) {
        let node: *u32 = ((node_prev as u32) + size) as *u32;
        *node_prev = node as u32;
        node_prev = node;        
    }
    *node_prev = 0;
    let node: *u32 = slab; 
    /* ensure that we have the correct number of elements and that they are each
     * an offset of size away from each other */
    i = 0;
    while (node != null) {
        if (*node - (node as u32) != size && *node != 0) {
            ERR;
        }
        node = *node as *u32;
        i+=1;
    };

    /* should divide evenly */
    if (i != (SLAB_SIZE/size)) {
        ERR;
    }
    cache->slab = slab;
}

/* creates a cache with a single slab, full of size-sized elements */
fn cache_create(size: u32, cache: *cache_descriptor) {
  /* ensure this is a power of two */
  assert (size&1 != 1 && size >= UINT_SIZE);
  cache->size = size;
  slab_add(size, cache);
  if (cache->slab == null) {
    ERR; // this shouldn't always be true, but is currently useful for debugging 
  }
}

/* remove an element from the given cache.  if cache is empty, a new slab is
 * allocated  */
fn cache_remove (cache: *cache_descriptor) -> *u32 {
  if (cache->slab == null) {
    slab_add(cache->size, cache);
  }
  
  let element: *u32 = cache->slab;
  if (element != null) {
    cache->slab = *element as *u32;
  }
  element
}

/* add element back into cache */
fn cache_add (element: *u32, cache: *cache_descriptor) {
  /* TODO check memory bounds */
  *element = cache->slab as u32;
  cache->slab = element;
}

fn alloc_init(head: *list_head) {
  caches = malloc(1000 * (POWER_MAX - POWER_MIN));
  let i: u32;
  for (i = POWER_MIN; i <= POWER_MAX; i+=1) {
    let cache = &caches[i - POWER_MIN];
    cache_create(1 << i, cache);
  }
}

/* returns the index of the correct cache for the given size */
fn find_cache(size: u32) -> i32 {
    let power: u32;
    for (power = POWER_MIN; power <= POWER_MAX; power +=1) {
        if (size <= (1 << power)) {
          return (power - POWER_MIN) as i32;
        }     
    }
    -1
}

fn slub_alloc(size: u32) -> *u32 {
    let cache_num: i32 = find_cache(size);
    print_int(cache_num);
    if (cache_num == -1) {
      return malloc(size);
    }
    // TODO check bounds 
    let cache: cache_descriptor = caches[cache_num as u32];
    cache_remove(&cache)
}

fn slub_free(head: *list_head, element: *u32, size: u32) {
    let cache_num: i32 = find_cache(size);
    print_int(cache_num);
    if (cache_num == -1) {
      //free(element);
      return ();
    }
    cache_add(element, &(caches[cache_num as u32]))
}

// we probs want some metadata about where each object came from?

fn main() -> i32 {
    list_init_head(&head);
    alloc_init(&head);
    print_uint(slub_alloc(15) as u32);
    0
}

