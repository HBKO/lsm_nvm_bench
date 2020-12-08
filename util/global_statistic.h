
#include <stdint.h>
#include <sys/time.h>
#include <stdlib.h>
#include <string>
#pragma once

#define STATISTIC_OPEN

#ifdef STATISTIC_OPEN
    struct GLOBAL_STATS {
        uint64_t compaction_num;
        uint64_t pick_compaction_time;
        uint64_t l0_get_time;
        uint64_t l0_find_num;
        uint64_t l0_read_time;
        uint64_t l0_search_time;
        uint64_t start_time;
        uint64_t l0_find_files_time;
	uint64_t l0_flush_bytes;
	uint64_t l0_l1_compact_bytes;
//	std::string* pmFilePath;


        GLOBAL_STATS(){
            compaction_num = 0;
            pick_compaction_time = 0;
            l0_get_time = 0;
            l0_find_num = 0;
            start_time = 0;
            l0_read_time = 0;
            l0_search_time = 0;
            l0_find_files_time = 0;
	    l0_flush_bytes = 0;
	    l0_l1_compact_bytes = 0;
//	    pmFilePath = new std::string("/pmem0/ayj_lsm_nvm/");
        }
    };
    extern struct GLOBAL_STATS global_stats;
    
#endif

uint64_t get_now_micros();

