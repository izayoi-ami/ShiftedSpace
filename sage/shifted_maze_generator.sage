import argparse
load("shifted_maze.sage")

def main():
    parser = argparse.ArgumentParser("Shifted Map Generator.")
    parser.add_argument("-m", action="store_true",  default=False)
    parser.add_argument("-s", action="store_true",  default=False)
    parser.add_argument("-o", "--output", nargs='?', type=argparse.FileType("w"), default=sys.stdout)
    parser.add_argument("rows", type=int)
    parser.add_argument("cols", type=int)
    parser.add_argument("floors", type=int, nargs="?", const=3, default=3)
    parser.add_argument("height", type=int, nargs="?", const=3, default=3)
    parser.add_argument("corridor", type=int, nargs="?", const=3, default=3)
    args = parser.parse_args()

    lang = "red"
    if args.m:
        lang = "mc"
    elif args.s:
        lang = "slow_red"
    SM=ShiftedMaze(args.rows,args.cols,height=args.height,level=args.floors, corridor=args.corridor, lang = lang)
    args.output.write(SM.lang())

if __name__ == "__main__":
    main()
