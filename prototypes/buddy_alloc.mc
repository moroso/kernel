#include "list.mh"

fn print_int(x: i32) {}
fn print_uint(x: u32) { print_int(x as i32); }
fn print_char(x: u32) {}
fn print_newline() { print_char(10); }

fn calloc<T>(i: u32, c: u32) -> *T { 0 as *T }


// Bitmaps!
struct bitmap {
    bits: *u32
}

fn bm_get_idx(n: u32) -> u32 { n / 32 }
fn bm_get_off(n: u32) -> u32 { n % 32 }
fn bm_get_mask(n: u32) -> u32 { 1 << bm_get_off(n) }

fn bm_get_bit(bm: *bitmap, n: u32) -> bool {
    (bm->bits[bm_get_idx(n)] & bm_get_mask(n)) != 0
}
fn bm_set_bit(bm: *bitmap, n: u32) {
    bm->bits[bm_get_idx(n)] = bm->bits[bm_get_idx(n)] | bm_get_mask(n);
}
fn bm_clear_bit(bm: *bitmap, n: u32) {
    bm->bits[bm_get_idx(n)] = bm->bits[bm_get_idx(n)] & ~bm_get_mask(n);
}

// The allocator!
#define BITS 32

#define MAX_ORDER 12

struct buddy_category {
    bitmap: bitmap,
    free_list: list_head
}

struct buddy_arena {
    zones: buddy_category[/*MAX_ORDER+1*/13],
    nodes: *list_node
}

// Total amount needs to be divisible by 4MB

// This is kind of bogus but whatever.
// Don't bother checking errors b/c it is boot code anyways
// And tbh just test code
fn buddy_init(num_frames: u32) -> *buddy_arena {
    let node_size: u32 = 8;
    let arena_size: u32 = node_size + (4+node_size)*(MAX_ORDER+1);
    let arena: *buddy_arena = calloc(1, arena_size);

    arena->nodes = calloc(num_frames, node_size);

    // We just add 1 instead of bothering to round up only if necessary
    let num_words: u32 = num_frames / BITS + 1;

    let i: u32;
    for (i = 0; i <= MAX_ORDER; i += 1) {
        let zone: *buddy_category = &arena->zones[i];
        list_init_head(&zone->free_list);

        zone->bitmap.bits = calloc(4, num_words+1);

        num_words /= 2;
    };

    arena
}


fn _get_buddy(block: u32, order: u32) -> u32 {
    block ^ (1 << order)
}

fn _get_index(arena: *buddy_arena, node: *list_node) -> u32 {
    node - arena->nodes
}
fn _get_node(arena: *buddy_arena, block: u32) -> *list_node {
    &arena->nodes[block]
}



fn _split_block(arena: *buddy_arena, block: u32,
                cur_order: u32, target_order: u32) {
    while (cur_order > target_order) {
        let zone: *buddy_category = &arena->zones[cur_order-1];

        // Find our buddy
        let buddy_block: u32 = _get_buddy(block, cur_order-1);
        // Add it to the free list
        // XXX: this next line is the fucked one
        let node: *list_node = _get_node(arena, buddy_block);
        list_insert_head(node, &zone->free_list);
        // Mark it as free
        //print_char(105); print_uint(buddy_block);
        bm_set_bit(&zone->bitmap, buddy_block);

        cur_order = cur_order - 1;

    }
}

// Returns -1 on failure
fn buddy_alloc(arena: *buddy_arena, order: u32) -> i32 {
    let cur_order: u32;
    // Search the different orders
    for (cur_order = order; cur_order <= MAX_ORDER; cur_order += 1) {
        // Do we have a block bigger than us?
        let zone: *buddy_category = &arena->zones[cur_order];
        let zone_list: *list_head = &zone->free_list;

        if (!list_is_empty(zone_list)) {
            // Pop it off the list

            let node: *list_node = zone->free_list.next;
            list_del(node);
            // Grab it.
            let block: u32 = _get_index(arena, node);
            _split_block(arena, block, cur_order, order);

            // Mark it allocated in the bitmap
            bm_clear_bit(&zone->bitmap, block);

            return block as i32;
        }
    };

    // Nothing
    -1
}

fn buddy_free(arena: *buddy_arena, block: u32, order: u32) {

    while (order < MAX_ORDER) {
        let zone: *buddy_category = &arena->zones[order];
        let buddy: u32 = _get_buddy(block, order);
        // No buddy. Done merging
        if (!bm_get_bit(&zone->bitmap, buddy)) { break; };

        // Mark the buddy as not free
        bm_clear_bit(&zone->bitmap, buddy);
        let buddy_node: *list_node = _get_node(arena, buddy);
        // Take the buddy off the free list
        list_del(buddy_node);

        // Take the lower block.
        if (buddy < block) {
            block = buddy;
        };

        order += 1;
    };

    //print_char(111); print_uint(order);
    let zone: *buddy_category = &arena->zones[order];
    let node: *list_node = _get_node(arena, block);
    list_insert_head(node, &zone->free_list);
    bm_set_bit(&zone->bitmap, block);
}


/////////////////////////// Testing

fn buddy_alloc2(arena: *buddy_arena, order: u32) -> u32 {
    buddy_alloc(arena, order) as u32
}

fn small_test(arena: *buddy_arena) {
    let n1: u32 = buddy_alloc2(arena, 0);
    print_newline();
    let n2: u32 = buddy_alloc2(arena, 0);
    let n3: u32 = buddy_alloc2(arena, 0);
    let n4: u32 = buddy_alloc2(arena, 0);
    let n5: u32 = buddy_alloc2(arena, 0);

    print_newline();

    print_uint(n1);
    print_uint(n2);
    print_uint(n3);
    print_uint(n4);
    print_uint(n5);

    buddy_free(arena, n1, 0);
    buddy_free(arena, n2, 0);
    buddy_free(arena, n3, 0);
    buddy_free(arena, n4, 0);
    buddy_free(arena, n5, 0);
}

fn main() -> u32 {
    let num_big_blocks = 2;
    let small_blocks_per = 1 << MAX_ORDER;

    let arena: *buddy_arena = buddy_init(small_blocks_per * num_big_blocks);
    let i: u32;
    for (i = 0; i < num_big_blocks; i += 1) {
        buddy_free(arena, i * small_blocks_per, MAX_ORDER);
    };

    small_test(arena);
    small_test(arena);

    let big_stig = buddy_alloc2(arena, MAX_ORDER);
    let big_stig2 = buddy_alloc2(arena, MAX_ORDER);
    print_newline();
    print_uint(big_stig);
    print_uint(big_stig2);

    buddy_free(arena, big_stig, MAX_ORDER);

    small_test(arena);

    0
}
