#include <slub_pmm.h>
#include <string.h>
#include <assert.h>
#include <list.h>

#define SLAB_MIN_ORDER 3  // 最小 slab 大小（2^3 = 8字节）
#define SLAB_MAX_ORDER 6  // 最大 slab 大小（2^6 = 64字节）
#define PGSIZE 4096       // 每页大小为 4096 字节
#define MAX_PAGES 1024    // 最大页面数

// 定义 slab_cache 数组，分别管理不同大小的 slab
static struct slab_cache slab_caches[SLAB_MAX_ORDER - SLAB_MIN_ORDER + 1];
static struct Page page_pool[MAX_PAGES]; // 静态分配的页面池
static size_t allocated_pages = 0;       // 已分配的页数

// 实现 list_size 函数，用于计算链表中元素的数量
static inline size_t list_size(struct list_entry *head) {
    size_t count = 0;
    struct list_entry *entry = head->next;
    while (entry != head) {
        count++;
        entry = entry->next;
    }
    return count;
}

// 初始化 SLUB 分配器
void slub_init(void) {
    for (int i = 0; i < SLAB_MAX_ORDER - SLAB_MIN_ORDER + 1; i++) {
        list_init(&slab_caches[i].free_list);
        slab_caches[i].free_count = 0;
    }
    allocated_pages = 0;
}

// 初始化内存映射，分配 slab 缓存
void slub_init_memmap(struct Page *base, size_t n) {
    for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
        size_t slab_size = 1 << order; // slab 对象大小为 2^order 字节
        struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
        cache->objsize = slab_size;
        cache->total_objects = PGSIZE / slab_size; // 每页的对象数量

        // 初始化 slab 内存区域
        for (size_t i = 0; i < n; i++) {
            struct Page *page = base + i;
            list_add(&cache->free_list, &page->page_link);  // 将所有页加入空闲链表
            cache->free_count++;
        }
    }
}

// 静态分配页面
struct Page* static_alloc_pages(size_t n) {
    if (allocated_pages + n > MAX_PAGES) {
        return NULL; // 分配失败，页面不足
    }
    struct Page* page = &page_pool[allocated_pages];
    allocated_pages += n;
    return page;
}

// 分配内存页
struct Page* slub_alloc_pages(size_t n) {
    if (n == 1) {
        // 尝试从不同的 slab_cache 中找到合适大小的 slab
        for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
            struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
            if (!list_empty(&cache->free_list)) {
                // 从空闲链表中分配一个 slab
                struct Page *page = le2page(list_next(&cache->free_list), page_link);
                list_del(&page->page_link);  // 从链表中移除
                cache->free_count--;
                return page;
            }
        }

        // 如果找不到合适的 slab，尝试分配一个新的页
        struct Page* new_page = static_alloc_pages(1);  // 静态分配一个页
        if (new_page != NULL) {
            // 将新分配的页添加到 slab 缓存
            for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
                struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
                list_add(&cache->free_list, &new_page->page_link);
                cache->free_count++;
                return new_page;  // 返回新分配的页
            }
        }
    }
    return NULL;  // 如果找不到合适的 slab 或静态分配失败，返回 NULL
}

// 释放内存页
void slub_free_pages(struct Page *base, size_t n) {
    if (n == 1) {
        // 将内存页重新加入对应的 slab 缓存
        for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
            struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
            list_add(&cache->free_list, &base->page_link);  // 加入空闲链表
            cache->free_count++;
            return;
        }
    }
}

// 获取剩余的空闲页数
size_t slub_nr_free_pages(void) {
    size_t total_free_pages = 0;
    for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
        struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
        total_free_pages += cache->free_count;
    }
    return total_free_pages;
}

// 验证 SLUB 分配器的正确性
void slub_check(void) {
    size_t all_pages = slub_nr_free_pages();
    struct Page *p0, *p1, *p2;

    // 测试分配和释放
    p0 = slub_alloc_pages(1);
    assert(p0 != NULL);
    p1 = slub_alloc_pages(1);
    assert(p1 != NULL);
    p2 = slub_alloc_pages(1);
    assert(p2 != NULL);

    // 测试释放
    slub_free_pages(p0, 1);
    slub_free_pages(p1, 1);
    slub_free_pages(p2, 1);

    // 确认所有页数都正确释放
    assert(slub_nr_free_pages() == all_pages);

    // cprintf("SLUB allocator test passed.\n");
}

// 定义 SLUB 分配器管理结构
const struct pmm_manager slub_pmm_manager = {
    .name = "slub_pmm_manager",
    .init = slub_init,
    .init_memmap = slub_init_memmap,
    .alloc_pages = slub_alloc_pages,
    .free_pages = slub_free_pages,
    .nr_free_pages = slub_nr_free_pages,
    .check = slub_check,
};
