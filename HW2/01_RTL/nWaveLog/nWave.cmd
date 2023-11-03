verdiSetActWin -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/raid7_2/userb10/b10176/Computer_Architecture/HW2/01_RTL/HW2.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/test_HW2"
wvGetSignalSetScope -win $_nWave1 "/test_HW2/U0"
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSetPosition -win $_nWave1 {("G1" 6)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/test_HW2/U0/i_clk} \
{/test_HW2/U0/inst\[2:0\]} \
{/test_HW2/U0/o_done} \
{/test_HW2/U0/operand_a\[31:0\]} \
{/test_HW2/U0/operand_b\[31:0\]} \
{/test_HW2/U0/out\[63:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 )} 
wvSetPosition -win $_nWave1 {("G1" 6)}
wvGetSignalClose -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/test_HW2"
wvGetSignalSetScope -win $_nWave1 "/test_HW2/U0"
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 9)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/test_HW2/U0/i_clk} \
{/test_HW2/U0/inst\[2:0\]} \
{/test_HW2/U0/o_done} \
{/test_HW2/U0/operand_a\[31:0\]} \
{/test_HW2/U0/operand_b\[31:0\]} \
{/test_HW2/U0/out\[63:0\]} \
{/test_HW2/U0/i_A\[31:0\]} \
{/test_HW2/U0/i_B\[31:0\]} \
{/test_HW2/U0/i_inst\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 7 8 9 )} 
wvSetPosition -win $_nWave1 {("G1" 9)}
wvGetSignalClose -win $_nWave1
wvZoomAll -win $_nWave1
