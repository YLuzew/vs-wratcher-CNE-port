function postCreate()
{
    {
        for (i in 0...4) {
            playerStrums.members[i].x = 434 + i * 105; // 435 → 434 (-1)
            cpuStrums.members[i].y = 50 + i;
            playerStrums.members[i].y = 40 + i;
        }
        for (i in 3...4) {
            playerStrums.members[i].x = 436 + i * 105; // 437 → 436 (-1)
            playerStrums.members[i].y = 38 + i;
        }
        for (i in 2...4) {
            cpuStrums.members[i].x = 770 + i * 105; // 771 → 770 (-1)
            cpuStrums.members[i].y = 47 + i;
        }
        for (i in 0...2) {
            cpuStrums.members[i].x = 94 + i * 105; // 95 → 94 (-1)
        }

        // 隐藏非玩家（对手）的扫弦线
        for (strum in cpuStrums.members) strum.visible = false;
    }
}

function update()
{
    {
        for (i in 0...4) {
            playerStrums.members[i].x = 434 + i * 105; // 435 → 434 (-1)
        }
        for (i in 3...4) {
            playerStrums.members[i].x = 436 + i * 105; // 437 → 436 (-1)
        }
        for (i in 2...4) {
            cpuStrums.members[i].x = 770 + i * 105; // 771 → 770 (-1)
        }
        for (i in 0...2) {
            cpuStrums.members[i].x = 94 + i * 105; // 95 → 94 (-1)
        }
    }
}
