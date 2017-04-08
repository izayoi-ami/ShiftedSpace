load("./block.sage")
import random

class MazeTree:
    def __init__(self,m,n,doors=2,glasses=0):
        from itertools import groupby
        self.m,self.n=m,n
        d={ self.to_index_xy(i,j): map(self.to_index,self.adjacent((i,j))) for j in range(n) for i in range(m) }
        self.G= Graph(d)
        self.spanning_tree=self.G.random_spanning_tree()
        roads = []
        for k,g in groupby(self.spanning_tree, lambda p:p[0]):
            roads.append((k,map(lambda p:p[1],list(g))))

        self.roads = roads
        self.x,self.y = map(lambda x:2*x+1,(m,n))
        self.maze = [[ MazeTree.AnyBlock() if any(map(lambda x:x%2==0,(i,j))) else Floor() for j in range(self.y)] for i in range(self.x)]

        for s,L in roads:
            for d in L:
                x,y = self.wall_pos_between_two_map_index(s,d)
                self.maze[x][y]=Floor()

        self.add_random_glasses(glasses)
        self.add_random_doors(doors)

    @staticmethod
    def AnyBlock():
        lst=[Glass(),Wall(),Wall(),Glass(),Glass(),Glass(),Glass(),Wall(),Wall(),Wall()]
        return random.choice(lst)

    def add_door_to_maze(self,p):
        x,y=p
        self.maze[x][y]=Door()

    def add_random_doors(self,n=2):
        borders = self.borders()
        shuffle(borders)

        for k in range(n):
            self.add_door_to_maze(borders[k])
    
    def add_glass_to_maze(self,p):
        x,y=p
        self.maze[x][y]=Glass()

    def add_random_glasses(self,n=0):
        if n==0:
            n=(self.x+self.y)//2
        borders=self.shuffle_borders() 
        for k in range(n):
            self.add_glass_to_maze(borders[k])


    def borders(self):
        return [ (2*k+1,0) for k in range(self.m)] + [ (2*k+1,self.y-1) for k in range(self.m) ] + [ (0,2*k+1) for k in range(self.n)] + [ (self.x-1, 2*k+1) for k in range(self.n)]

    def shuffle_borders(self):
        borders=self.borders()
        shuffle(borders)
        return borders

    def wall_pos_between_two_map_index(self,s,d):
        md,ms=map(self.from_index,(d,s))
        dv=[md[i]-ms[i] for i in range(2)] 
        direction = map(sgn,dv)
        return map(lambda (x,y):x+y,zip(self.from_map_index_to_maze_pos(s),direction))

    def from_map_index_to_maze_pos(self,k):
        m,n=self.from_index(k)
        return map(lambda x:2*x+1,(m,n))

    def from_index(self,k):
        return (k%self.m,k//self.m)


    def to_index_xy(self,x,y):
        return self.to_index((x,y))

    def to_index(self,p):
        x,y=p
        return x+y*self.m

    def adjacent(self,p):
        x,y=p
        L=[(x+1,y),(x-1,y),(x,y+1),(x,y-1)]
        return filter(self.valid_position,L)

    def valid_position(self,p):
        return p[0] in [0 .. self.m-1] and p[1] in [0 .. self.n-1]

    def __str__(self):
        return "\n".join([ "".join(map(str,k)) for k in self.maze])

# def main():
    # import sys
    # if len(sys.argv)<3:
        # print "USAGE: sage tree_gen.sage rows cols [doors] [glasses]"
        # return
    # print MazeTree(*map(int,sys.argv[1:]))

# if __name__ == "__main__":
    # main()
