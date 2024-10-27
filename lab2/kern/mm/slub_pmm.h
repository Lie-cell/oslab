#ifndef __SLUB_PMM_MANAGER_H__
#define __SLUB_PMM_MANAGER_H__

#include <pmm.h>
#include <list.h>
#include <memlayout.h>
#include <assert.h>

struct slab_cache {
    size_t objsize;                 
    size_t total_objects;         
    size_t free_count;              
    struct list_entry free_list;    
};

struct Page* slub_alloc_pages(size_t n);
void slub_free_pages(struct Page *base, size_t n);
size_t slub_nr_free_pages(void);

extern const struct pmm_manager slub_pmm_manager;

#endif // __SLUB_PMM_MANAGER_H__