load("shifted_space_translator.sage")
load("maze_generator.sage")

class ShiftedMaze(object):
    def __init__(
            self, x,y, height=3, level=3, corridor=3, lang="red",
            floors = [[ShiftedFirstFloor], [ShiftedSecondFloor], [ShiftedThirdFloor]], 
            glasses =[[ShiftedFenceOne, ShiftedGlassOne, ShiftedGlassTwo]], 
            walls = [[ShiftedWallFirstOne, ShiftedWallFirstTwo, ShiftedWallFirstThree], [ShiftedWallSecondOne, ShiftedWallSecondTwo, ShiftedWallSecondThree], [ShiftedWallThirdOne, ShiftedWallThirdTwo, ShiftedWallThirdThree]]):
        self.M=[]
        self.T=[]
        self._lang=[]
        F,G,W = map(len,(floors,glasses,walls))
        offset=vector((1,0,1))
        h=vector((0,height+1,0))
        for f in range(level):
            M=MazeTree(x,y)
            ff,gg,ww = map(lambda t:f%t, (F,G,W))
            ceiling = f==level-1
            exit = f == 0 
            T=ShiftedSpaceTranslator(M.maze,height=height, corridor=corridor, ceiling=ceiling, exit=exit , offset=offset+f*h, floors=floors[ff], glasses=glasses[gg], walls=walls[ww])
            self.M += [M]
            self.T += [T]
            if lang == "mc":
                self._lang += [T.mc()]
            elif lang == "slow_red":
                self._lang += [T.red_dust()]
            else:
                self._lang += [T.fast_red_dust()]
            self._lang += [self.reset_builder()]

    def reset_builder(self):
        s=[
            "open maze",
            "translate 1 0 1",
            "close",
            ""
        ]
        return "\n".join(s)

    def lang(self):
        return "\n".join(self._lang)

