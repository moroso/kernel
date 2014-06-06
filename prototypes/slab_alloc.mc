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
#define SLAB_SIZE 100 /* this really isn't the right size*/
#define UINT_SIZE 4
#define CACHE_MIN 4
#define CACHE_MAX 4096

fn malloc<T>(i: u32) -> *T { 0 as *T }

struct cache_descriptor {
  size: u32,
  slab: *u32,
  link: list_node,
}

/* add a slab to the specified cache */
fn slab_add(cache: **cache_descriptor, size: u32) {    
    let slab: *u32 = malloc(SLAB_SIZE); 
    (*cache)->slab = slab;
    if (slab == null) {
      // return is not working 
    }; 
    
    let list_head: *u32 = slab; // stores linked list of slab pieces
    let node_prev: *u32 = list_head;
    let i: u32;

    /* split up slab into size-sized chunks and link them together with the first
     * word of each chunk */
    for (i = size; i < SLAB_SIZE; i+=size) {
        /* TODO find a replacement for this bullshit */
        let tmp: u32 = (list_head as u32) + i;
        tmp+=i;
        let node_cur: *u32 = (tmp as *u32);

        *node_prev = (node_cur as u32);
        node_prev = node_cur;
    }  
    /* mark the final element as NULL */
    *node_prev = 0;
}

fn cache_init(cache: **cache_descriptor, size: u32) {
    (*cache)->size = size;
    slab_add(cache, size);
}

/* create a new cache of 'size'-sized elements.  last element might be a bit
 * larger if the slab doesn't divide evenly */
fn cache_create(size: u32) -> *u32 {

    if size < UINT_SIZE || size > SLAB_SIZE { 
        return null
    };

    let tmp: *u32 = malloc(32); // I dunno how big this shit is
    let cache: *cache_descriptor = tmp as *cache_descriptor; 
    
    if (cache != null) {
        cache_init(&cache, size);
    }

    cache as *u32
}

/* takes an element from the specified cache */
fn from_cache(cache: *cache_descriptor) -> *u32 {
    /* take an element and update the list */
    if (cache->slab == null) {
        slab_add(&cache, cache->size);
    }
    let element = cache->slab as *u32;

    if (element != null) {
        cache->slab = *element as *u32;    
    };
    element
} 

/* a performant solution would use something better than a linked list */
fn find_cache(size: u32, cache_head: *list_head) -> *u32 {

    let tmp: u32 = container_of(cache_head->next, cache_descriptor, link) as u32;
    let cache_node: *cache_descriptor = tmp as *cache_descriptor; 
    let i: u32;
    for (i = CACHE_MIN; i <= CACHE_MAX; i*=2) {
        if ((cache_node->size >= size)) {
            /* it's possible we should check to see if the slab exists */
            return cache_node as *u32;      
        };      
        tmp = container_of(cache_node->link.next, cache_descriptor, link) as u32; // macro does not work
        cache_node = tmp as *cache_descriptor;
        /* this is the closest thing we have to the right size */
    };

    null
}

/* I really wish we had globals */
fn mm_alloc(size: u32, cache_head: *list_head) -> *u32 {

    let i: u32; 
    /* this is done in a stupid way because sully's macros don't work */
    let tmp: u32 = container_of(cache_head->next, cache_descriptor, link) as u32;

    /* if size is to big, use the big allocator */
    if size > CACHE_MAX {
        return malloc(size);
    }    

    let cache_node: *cache_descriptor = find_cache(size, cache_head) as *cache_descriptor; 
    if (cache_node != null) {
        let element: *u32 = from_cache(cache_node);
        /* should probably check the other buckets */    
        return element;        
    }
    /* If we couldn't find anything, return empty */
    null
}

fn mm_free(size: u32, element: *u32, cache_head: *list_head) {
    let cache_node: *cache_descriptor = find_cache(size, cache_head) as *cache_descriptor; 
    *element = cache_node->slab as u32;
    cache_node->slab = element; 
}

/* creates the initial list of caches */
fn mm_alloc_init(head: *list_head) {
    let tmp = cache_create(CACHE_MIN) as *u32;
    list_init_head(head);

    /* create caches for a bunch of different sizes */ 
    let i: u32;
    for (i = CACHE_MIN; i <= CACHE_MAX; i*=2) {
        tmp = cache_create(i);
        if tmp == null {
            break;
        };
        list_insert_tail(&((tmp as *cache_descriptor)->link), head);
    };
}

fn main() -> u32 {
    let head: list_head;
    mm_alloc_init(&head);
    0
}

