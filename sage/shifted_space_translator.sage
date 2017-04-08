import random
import string

class ShiftedBlock(object):
    def __init__(self, x,  height, y, block_id = "", block_prefix="", size=8, chars = string.ascii_uppercase+string.digits, end=(0,0,0)):
        self.x = x
        self.y = y
        self.end = vector(end)
        self.height = height
        if block_id == "":
            self.block_id = block_prefix + ''.join(random.choice(chars) for x in range(size))

    def red_dust(self):
        return "write {} {} {} {} 0 {}  {}".format(self.x,self.height,self.y,self.aurora_block(), self.block_id, self.external_string() + "&" + self.external_dim() + "&" + self.solid_str())

    def mc(self):
        return "write {} {} {} {} 0".format(self.x,self.height,self.y,self.mc_str())

    def mc_str(self):
        pass
    
    def aurora_block(self):
        return "vrogojin_aurora:entityImportBlock"
    
    def shifted_lib(self):
        return "net.iwstudio.shiftedspace"

    def shifted_id(self):
        pass

    def external_string(self):
        return "external.libID=" + self.shifted_lib() + "&" + "external.objId=" + self.shifted_id()

    def external_dim(self):
        return "external.dimX={}&external.dimY={}&external.dimZ={}".format(*self.end)

    def solid_str(self):
        return "isSolid=true"

    def __repr__(self):
        return self.shifted_id()

    def __str__(self):
        return self.shifted_id()


class ShiftedFloor(ShiftedBlock):
    def mc_str(self):
        return "grass"

    def solid_str(self):
        return "isSolid=false"


class ShiftedFirstFloor(ShiftedFloor):
    def shifted_id(self):
        return "floor_1"


class ShiftedSecondFloor(ShiftedFloor):
    def shifted_id(self):
        return "floor_2"


class ShiftedThirdFloor(ShiftedFloor):
    def shifted_id(self):
        return "floor_3"


class ShiftedWall(ShiftedBlock):
    def mc_str(self):
        return "stone"


class ShiftedWallFirstOne(ShiftedWall):
    def shifted_id(self):
        return "wall_1_1"


class ShiftedWallFirstTwo(ShiftedWall):
    def shifted_id(self):
        return "wall_1_2"


class ShiftedWallFirstThree(ShiftedWall):
    def shifted_id(self):
        return "wall_1_3"


class ShiftedWallSecondOne(ShiftedWall):
    def shifted_id(self):
        return "wall_2_1"


class ShiftedWallSecondTwo(ShiftedWall):
    def shifted_id(self):
        return "wall_2_2"


class ShiftedWallSecondThree(ShiftedWall):
    def shifted_id(self):
        return "wall_2_3"


class ShiftedWallThirdOne(ShiftedWall):
    def shifted_id(self):
        return "wall_3_1"


class ShiftedWallThirdTwo(ShiftedWall):
    def shifted_id(self):
        return "wall_3_2"


class ShiftedWallThirdThree(ShiftedWall):
    def shifted_id(self):
        return "wall_3_3"


class ShiftedGlass(ShiftedBlock):
    def mc_str(self):
        return "glass"


class ShiftedGlassOne(ShiftedGlass):
    def shifted_id(self):
        return "glass_1"


class ShiftedGlassTwo(ShiftedGlass):
    def shifted_id(self):
        return "glass_2"


class ShiftedFenceOne(ShiftedGlass):
    def shifted_id(self):
        return "fence_1"


class ShiftedCeilingOne(ShiftedGlass):
    def shifted_id(self):
        return "ceiling_1"


class ShiftedSpaceTranslator(object):
    def __init__(self, maze, offset=(1,0,1), basis=[(1,0,0),(0,0,1),(0,1,0)],  height=3, corridor=3, ceiling=False, exit=False, floors=[], walls=[], glasses=[], prefix="", FastMode=True):
        self.maze = maze
        self.corridor = corridor
        self.floors = floors
        self.walls = walls
        self.glasses = glasses
        self.offset = vector(offset)
        self.basis = map(vector,basis)
        self.width = width = corridor
        self.height = height + 1
        self.x = len(maze)
        self.y = len(maze[0])
        self.maze_len = (self.x, self.y)
        self.dim = map(lambda x:(x-1)/2*(width+1)+1, (self.x,self.y) ) + [self.height]
        self.dx, self.dy, self.dz = self.dim
        self.exit = exit
        if ceiling:
            self.dz += 1
        self.prefix = prefix
        self.ceiling = ceiling
        chars = string.ascii_uppercase+string.digits
        if self.prefix == "":
            self.prefix = "maze-" + ''.join(random.choice(chars) for x in range(3))

        self.blocks=[[[]]]
        self.fast_blocks=[[[]]]
        self.constructed = False
        self.fast_constructed = False
        self._red_dust=""
        self._fast_red_dust=""
        self._mc=""
        self.P = [2^(-k) for k in range(self.height-1)]
        self.X = GeneralDiscreteDistribution(self.P)

    def red_dust(self):
        if not self.constructed:
            self.construct_blocks()
        if self._red_dust=="":
            begin_phrase = "\n".join([self.open_red_dust(), self.init_red_dust(), self.clear_red_dust()])
            s="\n".join([b.red_dust() for xs in self.blocks for ys in xs for b in ys])
            end_phrase = "\n".join([self.close_red_dust()])
            self._red_dust=begin_phrase + "\n" + s + "\n" + end_phrase + "\n"
        return self._red_dust

    def mc(self):
        if not self.constructed:
            self.construct_blocks()
        if self._mc=="":
            begin_phrase = "\n".join([self.open_red_dust(), self.init_red_dust(), self.clear_red_dust()])
            s="\n".join([b.mc() for xs in self.blocks for ys in xs for b in ys])
            end_phrase = "\n".join([self.close_red_dust()])
            self._mc=begin_phrase + "\n" + s + "\n" + end_phrase + "\n"
        return self._mc

    def fast_red_dust(self):
        if not self.fast_constructed:
            self.construct_fast_blocks()
        if self._fast_red_dust == "":
            begin_phrase = "\n".join([self.open_red_dust(), self.init_red_dust(), self.clear_red_dust()])
            s = "\n".join([b.red_dust() for b in self.fbs])
            end_phrase = "\n".join([self.close_red_dust()])
            self._fast_red_dust=begin_phrase + "\n" + s + "\n" + end_phrase + "\n"
        return self._fast_red_dust

    def pick_texture(self, c):
        if c in [" "]:
            return random.choice(self.floors)
        if c in ["w", "d"]:
            return random.choice(self.walls)
        if c in ["g"]:
            return random.choice(self.glasses)
        raise Exception("No available texture")

    def open_red_dust(self):
        return "open maze"

    def close_red_dust(self):
        return "close"

    def init_red_dust(self):
        return "translate {} {} {}".format(*self.offset)

    def clear_red_dust(self):
        return "clear {} {} {}".format(*self.coeff_to_space(self.dim))

    def coeff_to_space(self, coeff):
        return sum([a*v for a,v in zip(coeff,self.basis)])

    def layout_to_blocks(self, pair):
        width = self.width
        height = self.height
        dw = width - 1
        (x,y) = pair
        B = str(self.maze[x][y])
        if B == " ":
            return []
        sb = self.pick_texture(B)
        (a,b) = map(lambda x: (x//2)*(width+1) + x%2, pair)
        v=vector((a,b,1))
        dx,dy = map(lambda t: t%2 * dw, (x,y))
        dz = height - 2
        rdz = self.X.get_random_element()
        dz = dz - rdz
        dv = vector((dx,dy,dz))
        sv,sd = map(self.coeff_to_space, (v, dv))
        return [sb(*sv, end=sd)]

    def construct_fast_blocks(self):
        self.fbs=[]
        for x in range(self.x):
            for y in range(self.y):
                if self.exit and (x,y) in [(0,0),(1,0),(self.x-1,self.y-1),(self.x-1,self.y-2)]:
                    continue
                self.fbs += self.layout_to_blocks((x,y))
        self.fbs += self.fast_floor()
        self.fbs += self.fast_ceiling()
        self.fast_constructed=True

    def fast_ceiling(self):
        if not self.ceiling:
            return []
        v=vector((0,0,self.height))
        dv=vector((self.dx-1,self.dy-1,0))
        sv,sdv = map(self.coeff_to_space, (v,dv))
        return [ShiftedCeilingOne(*sv,end=sdv)]

    def fast_floor(self):
        v=vector((0,0,0))
        dv=vector((self.dx-1,self.dy-1,0))
        sv,sdv = map(self.coeff_to_space, (v,dv))
        return [self.pick_texture(" ")(*sv,end=sdv)]

    def layout_pair_to_coeff_list(self,pair):
        width = self.width
        (x,y) = pair
        (a,b) = map(lambda x: (x//2)*(width+1) + x%2, pair)
        v=vector((a,b,0))
        (mx,my) = map(lambda t: max(1,t%2*width), pair)
        L=[v+vector((0+i,0+j,0)) for i in range(mx) for j in range(my)]
        if self.maze[x][y]!=" " and (x%2==0 or y%2==0):
            L=sum(map(lambda v:[v+vector((0,0,h)) for h in range(self.height - self.X.get_random_element())], L),[])
        if self.ceiling:
            L+=[v+vector((0+i,0+j,self.height)) for i in range(mx) for j in range(my)]
        return L
        
    def layout_pair_to_space_list(self, pair):
        L = self.layout_pair_to_coeff_list(pair)
        return map(self.coeff_to_space,L)

    def layout_to_red_dust(self, x, y):
        b=self.maze[x][y]
        s=str(b)
        sb=self.pick_texture(s)
        L=self.layout_pair_to_space_list((x,y))
        R=map(lambda (x,z,y):sb(x,y,z,block_prefix=self.prefix).red_dust(), L)
        return "\n".join(R)

    def construct_blocks_from_layout_pair(self, x, y):
        b=self.maze[x][y]
        s=str(b)
        sb=self.pick_texture(s)
        fb=self.pick_texture(" ")
        gb=self.pick_texture("g")
        L=self.layout_pair_to_coeff_list((x,y))
        for v in L:
            space=self.coeff_to_space(v)
            (a,c,b)=space
            if c==0:
                self.blocks[a][b] += [fb(*space, block_prefix=self.prefix)]
            elif c==self.height:
                self.blocks[a][b] += [gb(*space, block_prefix=self.prefix)]
            elif s!=" ":
                self.blocks[a][b] += [sb(*space,block_prefix=self.prefix)]
        
    def construct_blocks(self):
        self.blocks=[[[] for y in range(self.dy)] for x in range(self.dx)]
        for x in range(self.x):
            for y in range(self.y):
                if self.exit and  (x,y) in [(0,0),(1,0),(self.x-1,self.y-1),(self.x-1,self.y-2)]:
                    continue
                self.construct_blocks_from_layout_pair(x,y)
        self.constructed = True
