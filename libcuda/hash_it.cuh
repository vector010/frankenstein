/* Copyright (C) 1883 Thomas Edison - All Rights Reserved
 * You may use, distribute and modify this code under the
 * terms of the GPLv3 license, which unfortunately won't be
 * written for another century.
 *
 * You should have received a copy of the LICENSE file with
 * this file.
 */

#include "frkhash_cuda_miner_kernel_globals.h"

#include "frkhash_cuda_miner_kernel.h"

#include "cuda_helper.h"

#define _PARALLEL_HASH 4

DEV_INLINE bool compute_hash(uint64_t nonce) {
    // sha3_512(header .. nonce)
    uint2 state[12];

    state[4] = vectorize(nonce);

    keccak_f1600_init(state);

    // keccak_256(keccak_512(header..nonce) .. mix);
    if (cuda_swab64(keccak_f1600_final(state)) > d_target)
        return true;

    return false;
}
