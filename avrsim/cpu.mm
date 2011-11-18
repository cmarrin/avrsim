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

template<int r, int d>
int adc()
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

template<int r, int d>
int add()
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

typedef void (*OpcodeFunction)();

OpcodeFunction opcodes[6] = { NULL };

static void foo()
{
    opcodes[0] = (OpcodeFunction) &adc<0, 0>;
}


