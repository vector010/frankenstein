
#define OPENCL_PLATFORM_UNKNOWN 0
#define OPENCL_PLATFORM_AMD 1
#define OPENCL_PLATFORM_CLOVER 2
#define OPENCL_PLATFORM_NVIDIA 3
#define OPENCL_PLATFORM_INTEL 4

#ifdef cl_clang_storage_class_specifiers
#pragma OPENCL EXTENSION cl_clang_storage_class_specifiers : enable
#endif

#if defined(cl_amd_media_ops)
#if PLATFORM == OPENCL_PLATFORM_CLOVER
/*
 * MESA define cl_amd_media_ops but no amd_bitalign() defined.
 * https://github.com/openwall/john/issues/3454#issuecomment-436899959
 */
uint2 amd_bitalign(uint2 src0, uint2 src1, uint2 src2)
{
    uint2 dst;
    __asm(
        "v_alignbit_b32 %0, %2, %3, %4\n"
        "v_alignbit_b32 %1, %5, %6, %7"
        : "=v"(dst.x), "=v"(dst.y)
        : "v"(src0.x), "v"(src1.x), "v"(src2.x), "v"(src0.y), "v"(src1.y), "v"(src2.y));
    return dst;
}
#endif
#pragma OPENCL EXTENSION cl_amd_media_ops : enable
#elif defined(cl_nv_pragma_unroll)
uint amd_bitalign(uint src0, uint src1, uint src2)
{
    uint dest;
    asm("shf.r.wrap.b32 %0, %2, %1, %3;" : "=r"(dest) : "r"(src0), "r"(src1), "r"(src2));
    return dest;
}
#else
#define amd_bitalign(src0, src1, src2) \
    ((uint)(((((ulong)(src0)) << 32) | (ulong)(src1)) >> ((src2)&31)))
#endif

#if WORKSIZE % 4 != 0
#error "WORKSIZE has to be a multiple of 4"
#endif

static __constant uint2 const Keccak_f1600_RC[24] = {
    (uint2)(0x00000001, 0x00000000),
    (uint2)(0x00008082, 0x00000000),
    (uint2)(0x0000808a, 0x80000000),
    (uint2)(0x80008000, 0x80000000),
    (uint2)(0x0000808b, 0x00000000),
    (uint2)(0x80000001, 0x00000000),
    (uint2)(0x80008081, 0x80000000),
    (uint2)(0x00008009, 0x80000000),
    (uint2)(0x0000008a, 0x00000000),
    (uint2)(0x00000088, 0x00000000),
    (uint2)(0x80008009, 0x00000000),
    (uint2)(0x8000000a, 0x00000000),
    (uint2)(0x8000808b, 0x00000000),
    (uint2)(0x0000008b, 0x80000000),
    (uint2)(0x00008089, 0x80000000),
    (uint2)(0x00008003, 0x80000000),
    (uint2)(0x00008002, 0x80000000),
    (uint2)(0x00000080, 0x80000000),
    (uint2)(0x0000800a, 0x00000000),
    (uint2)(0x8000000a, 0x80000000),
    (uint2)(0x80008081, 0x80000000),
    (uint2)(0x00008080, 0x80000000),
    (uint2)(0x80000001, 0x00000000),
    (uint2)(0x80008008, 0x80000000),
};

#ifdef cl_amd_media_ops

#define ROTL64_1(x, y) amd_bitalign((x), (x).s10, 32 - (y))
#define ROTL64_2(x, y) amd_bitalign((x).s10, (x), 32 - (y))

#else

#define ROTL64_1(x, y) as_uint2(rotate(as_ulong(x), (ulong)(y)))
#define ROTL64_2(x, y) ROTL64_1(x, (y) + 32)

#endif


#define KECCAKF_1600_RND(a, i, outsz)                                      \
    do                                                                     \
    {                                                                      \
        const uint2 m0 = a[0] ^ a[5] ^ a[10] ^ a[15] ^ a[20] ^             \
                         ROTL64_1(a[2] ^ a[7] ^ a[12] ^ a[17] ^ a[22], 1); \
        const uint2 m1 = a[1] ^ a[6] ^ a[11] ^ a[16] ^ a[21] ^             \
                         ROTL64_1(a[3] ^ a[8] ^ a[13] ^ a[18] ^ a[23], 1); \
        const uint2 m2 = a[2] ^ a[7] ^ a[12] ^ a[17] ^ a[22] ^             \
                         ROTL64_1(a[4] ^ a[9] ^ a[14] ^ a[19] ^ a[24], 1); \
        const uint2 m3 = a[3] ^ a[8] ^ a[13] ^ a[18] ^ a[23] ^             \
                         ROTL64_1(a[0] ^ a[5] ^ a[10] ^ a[15] ^ a[20], 1); \
        const uint2 m4 = a[4] ^ a[9] ^ a[14] ^ a[19] ^ a[24] ^             \
                         ROTL64_1(a[1] ^ a[6] ^ a[11] ^ a[16] ^ a[21], 1); \
                                                                           \
        const uint2 tmp = a[1] ^ m0;                                       \
                                                                           \
        a[0] ^= m4;                                                        \
        a[5] ^= m4;                                                        \
        a[10] ^= m4;                                                       \
        a[15] ^= m4;                                                       \
        a[20] ^= m4;                                                       \
                                                                           \
        a[6] ^= m0;                                                        \
        a[11] ^= m0;                                                       \
        a[16] ^= m0;                                                       \
        a[21] ^= m0;                                                       \
                                                                           \
        a[2] ^= m1;                                                        \
        a[7] ^= m1;                                                        \
        a[12] ^= m1;                                                       \
        a[17] ^= m1;                                                       \
        a[22] ^= m1;                                                       \
                                                                           \
        a[3] ^= m2;                                                        \
        a[8] ^= m2;                                                        \
        a[13] ^= m2;                                                       \
        a[18] ^= m2;                                                       \
        a[23] ^= m2;                                                       \
                                                                           \
        a[4] ^= m3;                                                        \
        a[9] ^= m3;                                                        \
        a[14] ^= m3;                                                       \
        a[19] ^= m3;                                                       \
        a[24] ^= m3;                                                       \
                                                                           \
        a[1] = ROTL64_2(a[6], 12);                                         \
        a[6] = ROTL64_1(a[9], 20);                                         \
        a[9] = ROTL64_2(a[22], 29);                                        \
        a[22] = ROTL64_2(a[14], 7);                                        \
        a[14] = ROTL64_1(a[20], 18);                                       \
        a[20] = ROTL64_2(a[2], 30);                                        \
        a[2] = ROTL64_2(a[12], 11);                                        \
        a[12] = ROTL64_1(a[13], 25);                                       \
        a[13] = ROTL64_1(a[19], 8);                                        \
        a[19] = ROTL64_2(a[23], 24);                                       \
        a[23] = ROTL64_2(a[15], 9);                                        \
        a[15] = ROTL64_1(a[4], 27);                                        \
        a[4] = ROTL64_1(a[24], 14);                                        \
        a[24] = ROTL64_1(a[21], 2);                                        \
        a[21] = ROTL64_2(a[8], 23);                                        \
        a[8] = ROTL64_2(a[16], 13);                                        \
        a[16] = ROTL64_2(a[5], 4);                                         \
        a[5] = ROTL64_1(a[3], 28);                                         \
        a[3] = ROTL64_1(a[18], 21);                                        \
        a[18] = ROTL64_1(a[17], 15);                                       \
        a[17] = ROTL64_1(a[11], 10);                                       \
        a[11] = ROTL64_1(a[7], 6);                                         \
        a[7] = ROTL64_1(a[10], 3);                                         \
        a[10] = ROTL64_1(tmp, 1);                                          \
                                                                           \
        uint2 m5 = a[0];                                                   \
        uint2 m6 = a[1];                                                   \
        a[0] = bitselect(a[0] ^ a[2], a[0], a[1]);                         \
        a[0] ^= as_uint2(Keccak_f1600_RC[i]);                              \
        if (outsz > 1)                                                     \
        {                                                                  \
            a[1] = bitselect(a[1] ^ a[3], a[1], a[2]);                     \
            a[2] = bitselect(a[2] ^ a[4], a[2], a[3]);                     \
            a[3] = bitselect(a[3] ^ m5, a[3], a[4]);                       \
            a[4] = bitselect(a[4] ^ m6, a[4], m5);                         \
            if (outsz > 4)                                                 \
            {                                                              \
                m5 = a[5];                                                 \
                m6 = a[6];                                                 \
                a[5] = bitselect(a[5] ^ a[7], a[5], a[6]);                 \
                a[6] = bitselect(a[6] ^ a[8], a[6], a[7]);                 \
                a[7] = bitselect(a[7] ^ a[9], a[7], a[8]);                 \
                a[8] = bitselect(a[8] ^ m5, a[8], a[9]);                   \
                a[9] = bitselect(a[9] ^ m6, a[9], m5);                     \
                if (outsz > 8)                                             \
                {                                                          \
                    m5 = a[10];                                            \
                    m6 = a[11];                                            \
                    a[10] = bitselect(a[10] ^ a[12], a[10], a[11]);        \
                    a[11] = bitselect(a[11] ^ a[13], a[11], a[12]);        \
                    a[12] = bitselect(a[12] ^ a[14], a[12], a[13]);        \
                    a[13] = bitselect(a[13] ^ m5, a[13], a[14]);           \
                    a[14] = bitselect(a[14] ^ m6, a[14], m5);              \
                    m5 = a[15];                                            \
                    m6 = a[16];                                            \
                    a[15] = bitselect(a[15] ^ a[17], a[15], a[16]);        \
                    a[16] = bitselect(a[16] ^ a[18], a[16], a[17]);        \
                    a[17] = bitselect(a[17] ^ a[19], a[17], a[18]);        \
                    a[18] = bitselect(a[18] ^ m5, a[18], a[19]);           \
                    a[19] = bitselect(a[19] ^ m6, a[19], m5);              \
                    m5 = a[20];                                            \
                    m6 = a[21];                                            \
                    a[20] = bitselect(a[20] ^ a[22], a[20], a[21]);        \
                    a[21] = bitselect(a[21] ^ a[23], a[21], a[22]);        \
                    a[22] = bitselect(a[22] ^ a[24], a[22], a[23]);        \
                    a[23] = bitselect(a[23] ^ m5, a[23], a[24]);           \
                    a[24] = bitselect(a[24] ^ m6, a[24], m5);              \
                }                                                          \
            }                                                              \
        }                                                                  \
    } while (0)


#define KECCAK_PROCESS(st, in_size, out_size)    \
    do                                           \
    {                                            \
        for (int r = 0; r < 24; ++r)             \
        {                                        \
            int os = (r < 23 ? 25 : (out_size)); \
            KECCAKF_1600_RND(st, r, os);         \
        }                                        \
    } while (0)


typedef union
{
    uint uints[128 / sizeof(uint)];
    ulong ulongs[128 / sizeof(ulong)];
    uint2 uint2s[128 / sizeof(uint2)];
    uint4 uint4s[128 / sizeof(uint4)];
    uint8 uint8s[128 / sizeof(uint8)];
    uint16 uint16s[128 / sizeof(uint16)];
    ulong8 ulong8s[128 / sizeof(ulong8)];
} hash128_t;


typedef union
{
    ulong8 ulong8s[1];
    ulong4 ulong4s[2];
    uint2 uint2s[8];
    uint4 uint4s[4];
    uint8 uint8s[2];
    uint16 uint16s[1];
    ulong ulongs[8];
    uint uints[16];
} compute_hash_share;

// NOTE: This struct must match the one defined in CLMiner.cpp
struct SearchResults
{
    uint count;
    uint hashCount;
    volatile uint abort;
    uint gid[MAX_OUTPUTS];
};

//output             = arg 0
//header             = arg 1
//start_nonce        = arg 2
//target (boundary)  = arg 3

__attribute__((reqd_work_group_size(WORKSIZE, 1, 1))) __kernel void search(
    __global struct SearchResults* g_output,
    __constant uint2 const* g_header,
    ulong start_nonce,
    ulong target)
{
    if (g_output->abort)
        return;

    const uint thread_id = get_local_id(0) % 4;
    const uint hash_id = get_local_id(0) / 4;
    const uint gid = get_global_id(0);

    __local compute_hash_share sharebuf[WORKSIZE / 4];
    __local uint buffer[WORKSIZE];
    __local compute_hash_share* const share = sharebuf + hash_id;

    // sha3_512(header .. nonce)
    uint2 state[25];
    state[0] = g_header[0];
    state[1] = g_header[1];
    state[2] = g_header[2];
    state[3] = g_header[3];
    state[4] = as_uint2(start_nonce + gid);
    state[5] = as_uint2(0x0000000000000001UL);
    state[6] = (uint2)(0);
    state[7] = (uint2)(0);
    state[8] = as_uint2(0x8000000000000000UL);
    state[9] = (uint2)(0);
    state[10] = (uint2)(0);
    state[11] = (uint2)(0);
    state[12] = (uint2)(0);
    state[13] = (uint2)(0);
    state[14] = (uint2)(0);
    state[15] = (uint2)(0);
    state[16] = (uint2)(0);
    state[17] = (uint2)(0);
    state[18] = (uint2)(0);
    state[19] = (uint2)(0);
    state[20] = (uint2)(0);
    state[21] = (uint2)(0);
    state[22] = (uint2)(0);
    state[23] = (uint2)(0);
    state[24] = (uint2)(0);

    for (int pass = 0; pass < 2; ++pass)
    {
      // This is a very clever yet unintuitive solution
      // Classic case of Just because you can, doesn't mean you should
        KECCAK_PROCESS(state, select(5, 12, pass != 0), select(8, 1, pass != 0));
        if (pass > 0)
            break;

        state[12] = as_uint2(0x0000000000000001UL);
        state[13] = (uint2)(0);
        state[14] = (uint2)(0);
        state[15] = (uint2)(0);
        state[16] = as_uint2(0x8000000000000000UL);
        state[17] = (uint2)(0);
        state[18] = (uint2)(0);
        state[19] = (uint2)(0);
        state[20] = (uint2)(0);
        state[21] = (uint2)(0);
        state[22] = (uint2)(0);
        state[23] = (uint2)(0);
        state[24] = (uint2)(0);
    }

    if (get_local_id(0) == 0)
        atomic_inc(&g_output->hashCount);

    if (as_ulong(as_uchar8(state[0]).s76543210) <= target)
    {
        atomic_inc(&g_output->abort);
        uint slot = min(MAX_OUTPUTS - 1u, atomic_inc(&g_output->count));
        g_output->gid[slot] = gid;
    }
}

static void SHA3_512(uint2* s)
{
    uint2 st[25];

    for (uint i = 0; i < 8; ++i)
        st[i] = s[i];

    st[8] = (uint2)(0x00000001, 0x80000000);

    for (uint i = 9; i != 25; ++i)
        st[i] = (uint2)(0);

    KECCAK_PROCESS(st, 8, 8);

    for (uint i = 0; i < 8; ++i)
        s[i] = st[i];
}
