typedef unsigned char reg8;

reg8 regs[32];

class StatusRegister {
public:
    union {
        struct {
            bool c: 1;
            bool z: 1;
            bool n: 1;
            bool v: 1;
            bool s: 1;
            bool h: 1;
            bool t: 1;
            bool i: 1;
        };
        reg8 bits;
    };
};

StatusRegister sreg;

static int adc(int r, int d)
{
    reg8 rval = regs[r];
    reg8 dval = regs[d];
    reg8 x = rval + dval + sreg.c;
    
    sreg.h = (((dval & rval) | (rval & ~x) | (~x & dval)) & 0x08) != 0;
    sreg.v = (((dval & rval & ~x) | (~dval & ~rval & x)) & 0x80) != 0;
    sreg.n = (x & 0x80) != 0;
    sreg.s = sreg.n ^ sreg.v;
    sreg.z = x == 0;
    sreg.c = (((dval & rval) | (rval & ~x) | (~x & dval)) & 0x80) != 0;
    
    regs[d] = x;
    return 1;
}

template<int r, int d> int adc() { return adc(r, d); }

static int add(int r, int d)
{
    reg8 rval = regs[r];
    reg8 dval = regs[d];
    reg8 x = rval + dval + sreg.c;
    
    sreg.h = (((dval & rval) | (rval & ~x) | (~x & dval)) & 0x08) != 0;
    sreg.v = (((dval & rval & ~x) | (~dval & ~rval & x)) & 0x80) != 0;
    sreg.n = (x & 0x80) != 0;
    sreg.s = sreg.n ^ sreg.v;
    sreg.z = x == 0;
    sreg.c = (((dval & rval) | (rval & ~x) | (~x & dval)) & 0x80) != 0;
    
    regs[d] = x;
    return 1;
}

template<int r, int d> int add() { return add(r, d); }

typedef int (*OpcodeFunction)();

OpcodeFunction opcodes[6] = {
    &adc<0, 0>,
    &adc<0, 1>,
    &adc<0, 2>,
    &add<0, 0>,
    &add<0, 1>,
    &add<0, 2>
};

static void execOpcode()
{
    int result = opcodes[0]();
    result = opcodes[5]();
    if (result) { }
}

