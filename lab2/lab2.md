### 练习

对实验报告的要求：
 - 基于markdown格式来完成，以文本方式为主
 - 填写各个基本练习中要求完成的报告内容
 - 完成实验后，请分析ucore_lab中提供的参考答案，并请在实验报告中说明你的实现与参考答案的区别
 - 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
 - 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

#### 练习0：填写已有实验

本实验依赖实验1。请把你做的实验1的代码填入本实验中代码中有“LAB1”的注释相应部分并按照实验手册进行进一步的修改。具体来说，就是跟着实验手册的教程一步步做，然后完成教程后继续完成完成exercise部分的剩余练习。

#### 练习1：理解first-fit 连续物理内存分配算法（思考题）
first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合`kern/mm/default_pmm.c`中的相关代码，认真分析default_init，default_init_memmap，default_alloc_pages， default_free_pages等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。
请在实验报告中简要说明你的设计实现过程。请回答如下问题：
- 你的first fit算法是否有进一步的改进空间？

`default_init` 函数的作用是初始化内存管理相关的数据结构。在该函数中，首先调用 list_init(&free_list) 来初始化一个空的链表 free_list，这个链表用于记录空闲的内存块。接着，将全局变量 nr_free 设置为 0，这个变量用于跟踪当前可用的物理页面数,并将其初始化为0。

`default_init_memmap` 函数用于初始化一块内存区域，将其设置为可用的空闲块。具体功能包括：
- 确保传入的内存块大小 n 大于 0。
- 初始化每一页：
- 遍历从 base 开始的 n 页, 并确保每一页都是预留的，将每一页的 flags 和 property 字段设置为 0，表示这些页尚未被使用。将每一页的引用计数（ref）设置为 0，表明当前没有引用。
- 如果当前页是空闲块的第一页，则将其 property 设置为总页数 n，并调用 SetPageProperty(base) 来标记它为一个有效的块。
-将 nr_free 增加 n，更新可用的内存块总数。如果 free_list 为空，则直接将 base 页添加到列表中，否则，遍历 free_list，找到合适的位置将 base 页插入到列表中，以保持有序。
通过这些步骤，`default_init_memmap` 函数有效地将一块新的内存区域初始化为可用的空闲块，供后续的内存分配使用。

`default_alloc_pages` 函数用于从空闲页面列表中分配一块指定大小的内存块。具体流程如下：
- 首先确保请求的页面数 `n` 大于 0。若 `n` 大于当前空闲页面总数 `nr_free`，则返回 `NULL`，表示无法满足请求。
- 接着遍历 `free_list`，寻找第一个满足 `p->property >= n` 的页面块，通过 `le2page(le, page_link)` 获取当前遍历到的 `struct Page`。
- 如果找到了合适的空闲块 `page`，需要记录前一个元素 `prev` 以便后续操作。从 `free_list` 中删除该页面块，表示该页面块不再空闲。
- 如果该页面块的 `property` 大于 `n`，则计算剩余空闲块的数量，并更新其 `property`，- 创建一个指向剩余块的指针 `p`，并设置其 `property` 为剩余页面数。
- 将剩余块插入到 `free_list` 中。
- 最后从 `nr_free` 中减去分配的页面数 `n`，设置分配页面的状态，标记为已保留（`ClearPageProperty(page)`）。返回指向分配页面的指针 `page`。

如果未找到合适的空闲块，则函数返回 `NULL`。通过这个流程，`default_alloc_pages` 函数实现了动态内存分配的基本功能。

`default_free_pages` 函数用于将一块已分配的页面释放回空闲页面列表，并可能将相邻的小空闲块合并为更大的空闲块。其具体流程如下：

- 确保请求释放的页面数 `n` 大于 0。
- 接着和分配页面的步骤类似，遍历从 `base` 开始的 `n` 页（`struct Page` 结构体），确保这些页面不是预留的且没有标记为已分配，将每个页面的 `flags` 重置为 0。将引用计数设置为 0。
- 将 `base` 页的 `property` 设置为 `n`，表示这 `n` 页现在是空闲的，并调用 `SetPageProperty(base)` 进行标记。更新全局可用页面数 `nr_free`，增加 `n`。
- 如果空闲列表为空，则直接将 `base` 页添加到列表中，否则，遍历 `free_list`，找到合适的位置（按地址从低到高）插入 `base` 页。
- 在空闲列表中合并相邻的空闲块，检查 `base` 页之前的页，如果相邻的页（前一个页）的结束地址与 `base` 页的起始地址相等，则合并这两个块，更新属性并从空闲列表中删除 `base` 页。检查 `base` 页之后的页，如果相邻的页的起始地址与 `base` 页的结束地址相等，则也进行合并，并从空闲列表中删除相邻页。

通过这些步骤，`default_free_pages` 函数有效地将已释放的页面重新链接到空闲列表，并优化内存使用，减少内存碎片。

改进空间：first fit的思想是寻找到第一个合适大小的空闲页块，因此每次分配都需要从头开始查找，因此在遍历空闲块时，可以维护一个指向当前空闲块的指针，当发生分配或释放时，不必从头开始查找，可以从上次的位置继续查找。在一定程度上可以减少遍历的时间。
#### 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）
在完成练习一后，参考kern/mm/default_pmm.c对First Fit算法的实现，编程实现Best Fit页面分配算法，算法的时空复杂度不做要求，能通过测试即可。
请在实验报告中简要说明你的设计实现过程，阐述代码是如何对物理内存进行分配和释放，并回答如下问题：
- 你的 Best-Fit 算法是否有进一步的改进空间？

best_fit的分配思想是遍历空闲列表，查找满足需求的最小空闲块 ，因此在`best_fit_alloc_pages`函数中需要初始化一个`min_size`，每次遍历到`p->property >= n` 的页面块时，将它与当前的`min_size`对比，并更新`min_size`和`page`。
```
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            if(p->property<min_size){
            	min_size=p->property;
                page = p;
        }
    }
 }

```
之后的操作与default相同。
改进空间：因为best-fit算法是需要找到满足需求的最小空闲块，因此涉及到对目前空闲块大小比较的问题。因此可以使用更加高效的数据结构来存储空闲块的信息，比如AVL树，这样在遍历的时候，可以使用更短的时间搜索最合适的空闲块。

同样还可以通过维护不同大小的空闲块链表，每个链表存储特定大小范围的空闲块，来减少搜索时间。
#### 扩展练习Challenge：buddy system（伙伴系统）分配算法（需要编程）

Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...

 -  参考[伙伴分配器的一个极简实现](http://coolshell.cn/articles/10427.html)， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。
 
`buddy_init_memmap`中，初始化内存的初始状态。通过逐步增加 available_page_count 来确定在给定的页数 n 内，能够支持的最大页数。当可用页数加上计算出的值小于 n 时，将可用页数加倍；否则，停止循环。
```
    available_page_count = 1;
    for (int i = 1; i < BUDDY_MAX_DEPTH; i++) {
        if (available_page_count + ((2 * available_page_count - 1) / 1024) < n) {
            available_page_count *= 2;
        } else break;
    }
    
```

将 available_page_count 除以2，以得到最终的可用页数。接着计算伙伴系统中总的伙伴页数，并将伙伴页初始化，标记为保留状态。同时将剩余的页标记为可用，清除保留标志，设置页属性，并将引用计数设置为0。
最后初始化伙伴树。
```
    buddy_free_tree = (unsigned int*)KADDR(page2pa(base));
    for (int i = available_page_count; i < available_page_count * 2; i++) {
        buddy_free_tree[i] = 1;
    }
    for (int i = available_page_count - 1; i > 0; i--) {
        buddy_free_tree[i] = buddy_free_tree[i * 2] + buddy_free_tree[i * 2 + 1];
    }
```

`buddy_alloc_pages` 函数实现了伙伴系统中的页面分配功能。总的思想就是从伙伴树的根节点往下遍历，查找适合的空闲块，根据当前节点的左子节点和右子节点的空闲页面数，选择合适的子节点进行深入查找。
```
    while (1) {
        if (buddy_free_tree[LEFT_CHILD(index)] >= n) {
            index = LEFT_CHILD(index);
        } else if (buddy_free_tree[RIGHT_CHILD(index)] >= n) {
            index = RIGHT_CHILD(index);
        } else {
            break;
        }
    }
```
如果找到合适的空闲块，就进行一系列的分配操作，更新空闲块状态、计算页面的分配地址。
接着从分配的块向上更新其父节点的空闲数。每个父节点的值是其左右子节点的空闲数的最大值。
```
for (unsigned int parent_idx = PARENT(index); parent_idx > 0; parent_idx = PARENT(parent_idx)) {
        unsigned int left_child = LEFT_CHILD(parent_idx);
        unsigned int right_child = RIGHT_CHILD(parent_idx);
        buddy_free_tree[parent_idx] = MAX(buddy_free_tree[left_child], buddy_free_tree[right_child]);
    }
```
`buddy_free_pages` 函数实现了伙伴系统中的页面释放功能。
在释放页面时首先需要计算页面的索引，`start_index `是从可用页面起始地址到当前释放页面的偏移量，`index `是对应于伙伴树的索引。
```
    unsigned int start_index = (unsigned int)(base - available_page_start);
    unsigned int index = available_page_count + start_index;
```
接着对需要释放的页面进行处理。确保它们没有被保留且没有属性设置，将其标记为可用，并将引用计数设置为0。
```
unsigned int size = 1;
for (size_t i = 0; i < n; i++) {
    struct Page *p = base + i;
    assert(!PageReserved(p) && !PageProperty(p));
    SetPageProperty(p);
    set_page_ref(p, 0);
}
```
然后向上遍历伙伴树，查找当前释放块的父节点，并确定其大小。
```
for (; buddy_free_tree[index] > 0; index = PARENT(index)) {
    size *= 2;
}

```
接着需要维护伙伴树，从当前索引的父节点开始向上更新父节点的大小。每次更新时，如果左右子节点的空闲数之和等于当前节点的大小，则设置为 size；否则，取左右子节点的最大值。
```
buddy_free_tree[index] = size;
    for (index = PARENT(index); index > 0; index = PARENT(index)) {
        size *= 2;
        if (buddy_free_tree[LEFT_CHILD(index)] + buddy_free_tree[RIGHT_CHILD(index)] == size) {
            buddy_free_tree[index] = size;
        } else {
            buddy_free_tree[index] = MAX(buddy_free_tree[LEFT_CHILD(index)], buddy_free_tree[RIGHT_CHILD(index)]);
        }
    }

```

#### 扩展练习Challenge：任意大小的内存单元slub分配算法（需要编程）

slub算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。

 - 参考[linux的slub分配算法/](http://www.ibm.com/developerworks/cn/linux/l-cn-slub/)，在ucore中实现slub分配算法。要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

 

#### 扩展练习Challenge：硬件的可用物理内存范围的获取方法（思考题）
  - 如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？


> Challenges是选做，完成Challenge的同学可单独提交Challenge。完成得好的同学可获得最终考试成绩的加分。