import random

class Block(object):
    def __init__(self):
        self.passable=True

    def __str__(self):
        return "B"

    def __repr__(self):
        return self.__str__()

    @classmethod
    def mc_class(cls):
        return ""

    def mc_name(self):
        return "stonebrick"

    def param_list(self):
        return [["0"]]
    
    def param_str_list(self):
        return " ".join(self.param_list)

    def red_dust(self):
        pass
        mc_str = " ".join(self.mc_class,self.mc_name, self.param_str_list)
         


class Wall(Block):
    def __init__(self):
        super(Wall,self).__init__()
        self.passable=False

    def __str__(self):
        return "w"

class Floor(Block):
    def __init__(self):
        super((Floor),self).__init__()

    def __str__(self):
        return " "

class Door(Block):
    texture = ["wooden", "spruce", "birch", "jungle", "acacia", "dark_oak", "iron"]
    direction = { "w":0 ,"n":1 , "e":2 ,"s":3 }
    status = {"closed":0, "open":4}
    hinge = {"left":0 , "right":1 }
    power = {"unpowered":0, "powered": 2}
    part = {"lower":0, "upper":8}

    def __init__(self,**kwargs):
        super(Door,self).__init__()
        self.texture = "_".join([filter(None,kwargs.get("texture", random.choice(Door.texture))),"door"])
        self.direction = kwargs.get("direction", "w")
        self.status = kwargs.get("status", "open")
        self.hinge = kwargs.get("hinge", "left")
        self.power = kwargs.get("power", "powered")

    def __str__(self):
        return "d"

    def mc_name(self):
        return self.texture

    def lower(self):
        return Door.direction[self.direction] | Door.status[self.status] | Door.part["lower"]
    
    def upper(self):
        return Door.hinge[self.hinge] | Door.power[self.power] | Door.part["upper"] 

    def param_list(self):
        return map(lambda x:[str(x)],[self.lower(),self.right()])

class Glass(Block):
    def __init__(self):
        super(Glass,self).__init__()

    def __str__(self):
        return "g"

