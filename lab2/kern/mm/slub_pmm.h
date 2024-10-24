#ifndef __SLUB_PMM_MANAGER_H__
#define __SLUB_PMM_MANAGER_H__

#include <pmm.h>
#include <list.h>
#include <memlayout.h>
#include <assert.h>

// 定义 slab_cache 结构体
struct slab_cache {
    size_t objsize;                 // 对象大小
    size_t total_objects;           // 每页可以存放的对象总数
    size_t free_count;              // 当前空闲对象数量
    struct list_entry free_list;    // 空闲对象链表
};

// 初始化 SLUB 分配器
void slub_init(void);

// 初始化 slab 内存映射
void slub_init_memmap(struct Page *base, size_t n);

// 分配内存页
struct Page* slub_alloc_pages(size_t n);

// 释放内存页
void slub_free_pages(struct Page *base, size_t n);

// 获取剩余的空闲页数
size_t slub_nr_free_pages(void);

// 验证 SLUB 分配器的正确性
void slub_check(void);

// 声明全局的 SLUB 分配器管理结构
extern const struct pmm_manager slub_pmm_manager;

#endif // __SLUB_PMM_MANAGER_H__
