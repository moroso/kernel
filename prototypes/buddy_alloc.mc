#include "list.mh"

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
#define MAX_ORDER 12

struct buddy_category {
    bitmap: bitmap,
    free_list: list_head
}

struct buddy_arena {
    zones: buddy_category[MAX_ORDER],
    nodes: *list_node
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


// Returns -1 on failure
fn _split_block(arena: *buddy_arena, block: u32,
                cur_order: u32, target_order: u32) {
    while (cur_order > target_order) {
        let zone: *buddy_category = &arena->zones[cur_order];

        // Find our buddy
        let buddy_block: u32 = _get_buddy(block, cur_order);
        // Add it to the free list
        // XXX: this next line is the fucked one
        let node: *list_node = _get_node(arena, buddy_block);
        list_insert_head(node, &zone->free_list);
        // Mark it as free
        bm_set_bit(&arena->zones[cur_order-1].bitmap, buddy_block);

        cur_order = cur_order - 1;

    }
}


fn buddy_alloc(arena: *buddy_arena, order: u32) -> i32 {
    let cur_order: u32;
    // Search the different orders
    for (cur_order = order; cur_order <= MAX_ORDER; cur_order = cur_order+1) {
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
        let buddy_node: *list_node = _get_node(arena, block);
        // Take the buddy off the free list
        list_del(buddy_node);

        // Take the lower block.
        if (buddy < block) {
            block = buddy;
        };

        order += 1;
    };

    let zone: *buddy_category = &arena->zones[order];
    let node: *list_node = _get_node(arena, block);
    list_insert_head(node, &zone->free_list);
}
