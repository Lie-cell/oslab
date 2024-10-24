#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>

#define LEFT_CHILD(index)   (index*2)
#define RIGHT_CHILD(index)  ((index)*2+ 1)
#define PARENT(index)       (index/2)
#define MAX(a, b)           ((a) > (b) ? (a) : (b))
#define IS_POWER_OF_2(x)    (((x) & ((x) - 1)) == 0)
//#define LEFT_LEAF(index)    (LEFT_CHILD(index) + 1)
#define BUDDY_MAX_DEPTH     20
//#define RIGHT_LEAF(index)   (RIGHT_CHILD(index) + 1)


static unsigned int* buddy_free_tree; //用于存储一个节点的子树有多少个空闲页
static unsigned int total_buddy_pages; //伙伴页数目
static unsigned int available_page_count; //可用的页数目
static struct Page* available_page_start;
/*
// 计算 x 为 2 的幂次的值
static unsigned int find_next_power_of_2(unsigned int x) {
    if (x == 0) return 1; // 处理 0 的情况
    x--; // 为了处理非幂次的情况
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;
    return x + 1; // 得到下一个 2 的幂
}
*/
static void buddy_init(void) {}

static void buddy_init_memmap(struct Page *base, size_t n) {
    assert((n > 0));
    available_page_count = 1;
    for (int i = 1; i < BUDDY_MAX_DEPTH; i++) {
        if (available_page_count + ((2 * available_page_count - 1) / 1024) < n) {
            available_page_count *= 2;
        } else break;
    }
    available_page_count /= 2;
    total_buddy_pages = ((2 * available_page_count - 1) / 1024) + 1;
    available_page_start = base + total_buddy_pages;
    for (int i = 0; i < total_buddy_pages; i++) {
        SetPageReserved(base + i);
    }
    for (int i = total_buddy_pages; i < n; i++) {
        ClearPageReserved(base + i);
        SetPageProperty(base + i);
        set_page_ref(base + i, 0);
    }
    buddy_free_tree = (unsigned int*)KADDR(page2pa(base));
    for (int i = available_page_count; i < available_page_count * 2; i++) {
        buddy_free_tree[i] = 1;
    }
    for (int i = available_page_count - 1; i > 0; i--) {
        buddy_free_tree[i] = buddy_free_tree[i * 2] + buddy_free_tree[i * 2 + 1];
    }
}

struct Page* buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > buddy_free_tree[1]) {
        return NULL;
    }
    unsigned int index = 1;
    while (1) {
        if (buddy_free_tree[LEFT_CHILD(index)] >= n) {
            index = LEFT_CHILD(index);
        } else if (buddy_free_tree[RIGHT_CHILD(index)] >= n) {
            index = RIGHT_CHILD(index);
        } else {
            break;
        }
    }
    unsigned int allocated_size = buddy_free_tree[index];
    buddy_free_tree[index] = 0; 
    struct Page* allocated_page = &available_page_start[(index * allocated_size) - available_page_count];
    struct Page* end_page = allocated_page + allocated_size; 
    for (struct Page* p = allocated_page; p < end_page; p++) {
        ClearPageProperty(p);
        set_page_ref(p, 0);
    }
    for (unsigned int parent_idx = PARENT(index); parent_idx > 0; parent_idx = PARENT(parent_idx)) {
        unsigned int left_child = LEFT_CHILD(parent_idx);
        unsigned int right_child = RIGHT_CHILD(parent_idx);
        buddy_free_tree[parent_idx] = MAX(buddy_free_tree[left_child], buddy_free_tree[right_child]);
    }
    return allocated_page; 
}

void buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    unsigned int start_index = (unsigned int)(base - available_page_start);
    unsigned int index = available_page_count + start_index;
    unsigned int size = 1;
    for (size_t i = 0; i < n; i++) {
        struct Page *p = base + i;
        assert(!PageReserved(p) && !PageProperty(p));
        SetPageProperty(p);
        set_page_ref(p, 0);
    }
    for (; buddy_free_tree[index] > 0; index = PARENT(index)) {
        size *= 2;
    }

    buddy_free_tree[index] = size;
    for (index = PARENT(index); index > 0; index = PARENT(index)) {
        size *= 2;
        if (buddy_free_tree[LEFT_CHILD(index)] + buddy_free_tree[RIGHT_CHILD(index)] == size) {
            buddy_free_tree[index] = size;
        } else {
            buddy_free_tree[index] = MAX(buddy_free_tree[LEFT_CHILD(index)], buddy_free_tree[RIGHT_CHILD(index)]);
        }
    }
}

size_t buddy_nr_free_pages(void) {
    return buddy_free_tree[1];
}



static void
buddy_check(void) {
    int all_pages = nr_free_pages();
    struct Page* p0, *p1, *p2, *p3;
    // 分配过大的页数
    assert(alloc_pages(all_pages + 1) == NULL);
    // 分配两个组页
    p0 = alloc_pages(1);
    assert(p0 != NULL);
    p1 = alloc_pages(2);
    assert(p1 == p0 + 2);
    assert(!PageReserved(p0) && !PageProperty(p0));
    assert(!PageReserved(p1) && !PageProperty(p1));
    // 再分配两个组页
    p2 = alloc_pages(1);
    assert(p2 == p0 + 1);
    p3 = alloc_pages(8);
    assert(p3 == p0 + 8);
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
    // 回收页
    free_pages(p1, 2);
    assert(PageProperty(p1) && PageProperty(p1 + 1));
    assert(p1->ref == 0);
    free_pages(p0, 1);
    free_pages(p2, 1);
    // 回收后再分配
    p2 = alloc_pages(3);
    assert(p2 == p0);
    free_pages(p2, 3);
    assert((p2 + 2)->ref == 0);
    assert(nr_free_pages() == all_pages >> 1);

    p1 = alloc_pages(129);
    assert(p1 == p0 + 256);
    free_pages(p1, 256);
    free_pages(p3, 8);
}
//这个结构体在
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};

