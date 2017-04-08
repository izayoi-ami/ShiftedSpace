attach("shifted_space_translator.sage")
attach("maze_generator.sage")
M=MazeTree(10,10)
floors = [ShiftedFirstFloor]
glasses =[ShiftedGlassOne, ShiftedGlassTwo]
walls = [ShiftedWallFirstOne, ShiftedWallFirstTwo, ShiftedWallFirstThree]
SST=ShiftedSpaceTranslator
test=SST(M.maze,floors=floors,glasses=glasses, walls=walls)
print(M)
print(test.fast_red_dust())

